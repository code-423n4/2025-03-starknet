use core::num::traits::Zero;
use openzeppelin_testing::deployment::declare_and_deploy;
use openzeppelin_testing::signing::StarkKeyPair;
use perpetuals::core::components::assets::interface::{IAssetsDispatcher, IAssetsDispatcherTrait};
use perpetuals::core::components::deposit::Deposit::deposit_hash;
use perpetuals::core::components::deposit::interface::{
    DepositStatus, IDepositDispatcher, IDepositDispatcherTrait,
};
use perpetuals::core::components::operator_nonce::interface::{
    IOperatorNonceDispatcher, IOperatorNonceDispatcherTrait,
};
use perpetuals::core::components::positions::interface::{
    IPositionsDispatcher, IPositionsDispatcherTrait,
};
use perpetuals::core::core::Core::SNIP12MetadataImpl;
use perpetuals::core::interface::{ICoreDispatcher, ICoreDispatcherTrait};
use perpetuals::core::types::asset::{AssetId, AssetIdTrait};
use perpetuals::core::types::order::Order;
use perpetuals::core::types::position::PositionId;
use perpetuals::core::types::price::{PRICE_SCALE, SignedPrice};
use perpetuals::core::types::transfer::TransferArgs;
use perpetuals::core::types::withdraw::WithdrawArgs;
use perpetuals::tests::constants;
use perpetuals::tests::event_test_utils::{
    assert_deposit_event_with_expected, assert_deposit_processed_event_with_expected,
};
use perpetuals::tests::test_utils::validate_balance;
use snforge_std::cheatcodes::events::{Event, EventSpy, EventSpyTrait, EventsFilterTrait};
use snforge_std::signature::stark_curve::{StarkCurveKeyPairImpl, StarkCurveSignerImpl};
use snforge_std::{ContractClassTrait, DeclareResultTrait, start_cheat_block_timestamp_global};
use starknet::ContractAddress;
use starkware_utils::components::roles::interface::{IRolesDispatcher, IRolesDispatcherTrait};
use starkware_utils::constants::{DAY, HOUR, MAX_U128, MINUTE, TWO_POW_40};
use starkware_utils::message_hash::OffchainMessageHash;
use starkware_utils::test_utils::{
    Deployable, TokenConfig, TokenState, TokenTrait, cheat_caller_address_once,
};
use starkware_utils::types::time::time::{Time, TimeDelta, Timestamp};
use starkware_utils::types::{PublicKey, Signature};


const TIME_STEP: u64 = MINUTE;
const BEGINNING_OF_TIME: u64 = DAY * 365 * 50;

#[derive(Copy, Drop)]
pub struct User {
    pub position_id: PositionId,
    pub account: Account,
}

#[derive(Copy, Drop)]
pub struct Oracle {
    account: Account,
    name: felt252,
}

#[derive(Drop, Copy)]
pub struct DepositInfo {
    // position_id can represent a different user than the depositor.
    user: User,
    position_id: PositionId,
    amount: u64,
    salt: felt252,
}

#[derive(Drop)]
pub struct WithdrawInfo {
    // recipient can represent a different user than the withdrawer.
    user: User,
    recipient: ContractAddress,
    amount: u64,
    expiration: Timestamp,
    salt: felt252,
}

#[derive(Drop)]
pub struct TransferInfo {
    user: User,
    recipient: PositionId,
    amount: u64,
    expiration: Timestamp,
    salt: felt252,
}

#[generate_trait]
impl OracleImpl of OracleTrait {
    fn sign_price(
        self: @Oracle, oracle_price: u128, timestamp: u32, asset_name: felt252,
    ) -> SignedPrice {
        let packed_timestamp_price = (timestamp.into() + oracle_price * PRICE_SCALE.into()).into();
        let oracle_name_asset_name = *self.name + asset_name * TWO_POW_40.into();
        let msg_hash = core::pedersen::pedersen(oracle_name_asset_name, packed_timestamp_price);
        SignedPrice {
            signature: self.account.sign_message(msg_hash),
            signer_public_key: *self.account.key_pair.public_key,
            timestamp,
            oracle_price,
        }
    }
}

#[derive(Drop)]
struct PerpetualsConfig {
    operator: Account,
    governance_admin: ContractAddress,
    role_admin: ContractAddress,
    app_governor: ContractAddress,
    upgrade_delay: u64,
    collateral_id: AssetId,
    collateral_token_address: ContractAddress,
    collateral_quantum: u64,
    max_price_interval: TimeDelta,
    max_funding_interval: TimeDelta,
    max_funding_rate: u32,
    cancel_delay: TimeDelta,
    max_oracle_price_validity: TimeDelta,
    fee_position_owner_account: ContractAddress,
    fee_position_owner_public_key: PublicKey,
    insurance_fund_position_owner_account: ContractAddress,
    insurance_fund_position_owner_public_key: PublicKey,
}

#[generate_trait]
pub impl PerpetualsConfigImpl of PerpetualsConfigTrait {
    fn new(collateral_token_address: ContractAddress) -> PerpetualsConfig {
        let mut key_gen = 1;
        let operator = AccountTrait::new(ref key_gen);
        PerpetualsConfig {
            operator,
            governance_admin: constants::GOVERNANCE_ADMIN(),
            role_admin: constants::APP_ROLE_ADMIN(),
            app_governor: constants::APP_GOVERNOR(),
            upgrade_delay: constants::UPGRADE_DELAY,
            collateral_id: constants::COLLATERAL_ASSET_ID(),
            collateral_token_address,
            collateral_quantum: constants::COLLATERAL_QUANTUM,
            max_price_interval: constants::MAX_PRICE_INTERVAL,
            max_funding_interval: constants::MAX_FUNDING_INTERVAL,
            max_funding_rate: constants::MAX_FUNDING_RATE,
            cancel_delay: constants::CANCEL_DELAY,
            max_oracle_price_validity: constants::MAX_ORACLE_PRICE_VALIDITY,
            fee_position_owner_account: operator.address,
            fee_position_owner_public_key: operator.key_pair.public_key,
            insurance_fund_position_owner_account: operator.address,
            insurance_fund_position_owner_public_key: operator.key_pair.public_key,
        }
    }
}

impl PerpetualsContractStateImpl of Deployable<PerpetualsConfig, ContractAddress> {
    fn deploy(self: @PerpetualsConfig) -> ContractAddress {
        let mut calldata = ArrayTrait::new();
        self.governance_admin.serialize(ref calldata);
        self.upgrade_delay.serialize(ref calldata);
        self.collateral_id.serialize(ref calldata);
        self.collateral_token_address.serialize(ref calldata);
        self.collateral_quantum.serialize(ref calldata);
        self.max_price_interval.serialize(ref calldata);
        self.max_oracle_price_validity.serialize(ref calldata);
        self.max_funding_interval.serialize(ref calldata);
        self.max_funding_rate.serialize(ref calldata);
        self.cancel_delay.serialize(ref calldata);
        self.fee_position_owner_public_key.serialize(ref calldata);
        self.insurance_fund_position_owner_public_key.serialize(ref calldata);

        let perpetuals_contract = snforge_std::declare("Core").unwrap().contract_class();
        let (address, _) = perpetuals_contract.deploy(@calldata).unwrap();
        address
    }
}

/// Account is a representation of any user account that can interact with the contracts.
#[derive(Copy, Drop)]
struct Account {
    pub address: ContractAddress,
    pub key_pair: StarkKeyPair,
}

#[generate_trait]
impl AccountImpl of AccountTrait {
    fn new(ref key_gen: felt252) -> Account {
        let key_pair = StarkCurveKeyPairImpl::from_secret_key(key_gen);
        key_gen += 1;
        let address = declare_and_deploy("AccountUpgradeable", array![key_pair.public_key]);
        Account { key_pair, address }
    }

    fn set_as_caller(self: @Account, contract_address: ContractAddress) {
        cheat_caller_address_once(:contract_address, caller_address: *self.address);
    }

    fn sign_message(self: @Account, message: felt252) -> Signature {
        let (r, s) = (*self).key_pair.sign(message).unwrap();
        array![r, s].span()
    }

    fn get_order_signature(self: @Account, order: Order, public_key: felt252) -> Signature {
        let hash = order.get_message_hash(public_key);
        self.sign_message(hash)
    }
}

#[derive(Drop)]
pub struct SyntheticConfig {
    pub asset_name: felt252,
    pub asset_id: AssetId,
    pub risk_factor_tiers: Span<u8>,
    pub risk_factor_first_tier_boundary: u128,
    pub risk_factor_tier_size: u128,
    pub quorum: u8,
    pub resolution_factor: u64,
}

pub fn create_synthetic_config(asset_name: felt252) -> SyntheticConfig {
    SyntheticConfig {
        asset_name,
        asset_id: AssetIdTrait::new(value: asset_name),
        risk_factor_tiers: array![50].span(),
        risk_factor_first_tier_boundary: MAX_U128,
        risk_factor_tier_size: Zero::zero(),
        quorum: constants::SYNTHETIC_QUORUM,
        resolution_factor: constants::SYNTHETIC_RESOLUTION_FACTOR,
    }
}

#[derive(Drop)]
pub struct EventState {
    spy: EventSpy,
    event_index: u32,
}

/// FlowTestState is the main struct that holds the state of the flow tests.
#[derive(Drop)]
pub struct FlowTestState {
    governance_admin: ContractAddress,
    role_admin: ContractAddress,
    app_governor: ContractAddress,
    perpetuals_contract: ContractAddress,
    token_state: TokenState,
    key_gen: felt252,
    operator: Account,
    oracle_a: Oracle,
    oracle_b: Oracle,
    position_id_gen: u32,
    salt: felt252,
    event_info: EventState,
}

#[generate_trait]
impl PrivateEventStateImpl of PrivateEventStateTrait {
    fn get_next_event(
        ref self: EventState, contract_address: ContractAddress,
    ) -> @(ContractAddress, Event) {
        self.event_index += 1;
        let events = self.spy.get_events().emitted_by(contract_address).events;
        events[self.event_index - 1]
    }
}

#[generate_trait]
impl PrivateFlowTestStateImpl of PrivateFlowTestStateTrait {
    fn generate_position_id(ref self: FlowTestState) -> u32 {
        self.position_id_gen += 1;
        self.position_id_gen
    }
    fn get_nonce(self: @FlowTestState) -> u64 {
        let dispatcher = IOperatorNonceDispatcher { contract_address: *self.perpetuals_contract };
        self.operator.set_as_caller(*self.perpetuals_contract);
        dispatcher.get_operator_nonce()
    }

    fn set_app_governor_as_caller(self: @FlowTestState) {
        cheat_caller_address_once(
            contract_address: *self.perpetuals_contract, caller_address: *self.app_governor,
        );
    }
    fn set_app_role_admin_as_caller(self: @FlowTestState) {
        cheat_caller_address_once(
            contract_address: *self.perpetuals_contract, caller_address: *self.role_admin,
        );
    }
    fn set_governance_admin_as_caller(self: @FlowTestState) {
        cheat_caller_address_once(
            contract_address: *self.perpetuals_contract, caller_address: *self.governance_admin,
        );
    }

    fn set_roles(self: @FlowTestState) {
        let dispatcher = IRolesDispatcher { contract_address: *self.perpetuals_contract };

        self.set_governance_admin_as_caller();
        dispatcher.register_app_role_admin(*self.role_admin);

        self.set_app_role_admin_as_caller();
        dispatcher.register_app_governor(*self.app_governor);

        self.set_app_role_admin_as_caller();
        dispatcher.register_operator(account: *self.operator.address);
    }

    fn add_synthetic(self: @FlowTestState, synthetic_config: @SyntheticConfig) {
        let dispatcher = IAssetsDispatcher { contract_address: *self.perpetuals_contract };
        self.set_app_governor_as_caller();
        dispatcher
            .add_synthetic_asset(
                *synthetic_config.asset_id,
                risk_factor_tiers: *synthetic_config.risk_factor_tiers,
                risk_factor_first_tier_boundary: *synthetic_config.risk_factor_first_tier_boundary,
                risk_factor_tier_size: *synthetic_config.risk_factor_tier_size,
                quorum: *synthetic_config.quorum,
                resolution_factor: *synthetic_config.resolution_factor,
            );

        self.set_app_governor_as_caller();
        dispatcher
            .add_oracle_to_asset(
                *synthetic_config.asset_id,
                *self.oracle_a.account.key_pair.public_key,
                *self.oracle_a.name,
                *synthetic_config.asset_name,
            );

        self.set_app_governor_as_caller();
        dispatcher
            .add_oracle_to_asset(
                *synthetic_config.asset_id,
                *self.oracle_b.account.key_pair.public_key,
                *self.oracle_b.name,
                *synthetic_config.asset_name,
            );
    }
    fn generate_salt(ref self: FlowTestState) -> felt252 {
        self.salt += 1;
        self.salt
    }
}

/// FlowTestTrait is the interface for the FlowTestState struct. It is the sole way to interact with
/// the contract by calling the following wrapper functions.
#[generate_trait]
pub impl FlowTestStateImpl of FlowTestTrait {
    fn init() -> FlowTestState {
        start_cheat_block_timestamp_global(BEGINNING_OF_TIME);
        let mut key_gen = 1;
        let token_config = TokenConfig {
            name: constants::COLLATERAL_NAME(),
            symbol: constants::COLLATERAL_SYMBOL(),
            initial_supply: constants::INITIAL_SUPPLY,
            owner: constants::COLLATERAL_OWNER(),
        };
        let token_state = Deployable::deploy(@token_config);

        let perpetuals_config: PerpetualsConfig = PerpetualsConfigTrait::new(
            collateral_token_address: token_state.address,
        );
        let perpetuals_contract = Deployable::deploy(@perpetuals_config);

        FlowTestState {
            governance_admin: perpetuals_config.governance_admin,
            role_admin: perpetuals_config.role_admin,
            app_governor: perpetuals_config.app_governor,
            perpetuals_contract,
            token_state,
            key_gen,
            operator: perpetuals_config.operator,
            oracle_a: Oracle {
                account: AccountTrait::new(ref key_gen), name: constants::ORACLE_A_NAME,
            },
            oracle_b: Oracle {
                account: AccountTrait::new(ref key_gen), name: constants::ORACLE_B_NAME,
            },
            position_id_gen: 100,
            salt: 0,
            event_info: EventState { spy: snforge_std::spy_events(), event_index: 0 },
        }
    }

    fn setup(ref self: FlowTestState, synthetics: Span<SyntheticConfig>) {
        self.set_roles();
        for synthetic_config in synthetics {
            self.add_synthetic(synthetic_config);
        }
        advance_time(HOUR);
    }

    fn new_user(ref self: FlowTestState) -> User {
        let account = AccountTrait::new(ref self.key_gen);

        self.token_state.fund(account.address, constants::USER_INIT_BALANCE);

        let operator_nonce = self.get_nonce();
        let position_id = self.generate_position_id();
        let dispatcher = IPositionsDispatcher { contract_address: self.perpetuals_contract };
        self.operator.set_as_caller(self.perpetuals_contract);
        dispatcher
            .new_position(
                operator_nonce,
                position_id: position_id.into(),
                owner_public_key: account.key_pair.public_key,
                owner_account: account.address,
            );

        User { position_id: PositionId { value: position_id }, account }
    }

    fn price_tick(ref self: FlowTestState, synthetic_config: @SyntheticConfig, oracle_price: u128) {
        let timestamp = Time::now().seconds.try_into().unwrap();
        let oracle_a_signed_price = self
            .oracle_a
            .sign_price(:oracle_price, :timestamp, asset_name: *synthetic_config.asset_name);
        let oracle_b_signed_price = self
            .oracle_b
            .sign_price(:oracle_price, :timestamp, asset_name: *synthetic_config.asset_name);
        let signed_prices = array![oracle_a_signed_price, oracle_b_signed_price].span();
        advance_time(TIME_STEP);

        let operator_nonce = self.get_nonce();
        self.operator.set_as_caller(self.perpetuals_contract);
        IAssetsDispatcher { contract_address: self.perpetuals_contract }
            .price_tick(
                :operator_nonce,
                asset_id: *synthetic_config.asset_id,
                :oracle_price,
                :signed_prices,
            );
    }

    fn deposit(ref self: FlowTestState, user: User, reciever: User, amount: u64) -> DepositInfo {
        let user_balance_before = self.token_state.balance_of(user.account.address);
        let contract_balance_before = self.token_state.balance_of(self.perpetuals_contract);
        let expected_time = Time::now().add(delta: Time::days(1));

        let deposit_info = self.execute_deposit(:user, :reciever, :amount);

        let deposit_hash = deposit_hash(
            token_address: self.token_state.address,
            depositor: user.account.address,
            position_id: user.position_id,
            quantized_amount: amount,
            salt: deposit_info.salt,
        );

        assert_deposit_event_with_expected(
            spied_event: self.event_info.get_next_event(contract_address: self.perpetuals_contract),
            position_id: user.position_id,
            depositing_address: user.account.address,
            quantized_amount: amount,
            deposit_request_hash: deposit_hash,
        );

        validate_balance(
            token_state: self.token_state,
            address: user.account.address,
            expected_balance: user_balance_before - amount.into(),
        );
        validate_balance(
            token_state: self.token_state,
            address: self.perpetuals_contract,
            expected_balance: contract_balance_before + amount.into(),
        );

        let status = IDepositDispatcher { contract_address: self.perpetuals_contract }
            .get_deposit_status(:deposit_hash);
        if let DepositStatus::PENDING(timestamp) = status {
            assert!(timestamp == expected_time);
        } else {
            panic!("Deposit not found");
        }

        deposit_info
    }

    fn execute_deposit(
        ref self: FlowTestState, user: User, reciever: User, amount: u64,
    ) -> DepositInfo {
        self.token_state.fund(recipient: user.account.address, amount: amount.into());
        self
            .token_state
            .approve(
                owner: user.account.address,
                spender: self.perpetuals_contract,
                amount: amount.into(),
            );
        let salt = self.generate_salt();
        let position_id = reciever.position_id;
        user.account.set_as_caller(self.perpetuals_contract);

        IDepositDispatcher { contract_address: self.perpetuals_contract }
            .deposit(:position_id, quantized_amount: amount, :salt);
        DepositInfo { user, position_id, amount, salt }
    }

    fn cancel_deposit(ref self: FlowTestState, deposit_info: DepositInfo) {
        deposit_info.user.account.set_as_caller(self.perpetuals_contract);
        IDepositDispatcher { contract_address: self.perpetuals_contract }
            .cancel_deposit(
                position_id: deposit_info.position_id,
                quantized_amount: deposit_info.amount.into(),
                salt: deposit_info.salt,
            );
    }

    fn process_deposit(ref self: FlowTestState, deposit_info: DepositInfo) {
        self.execute_process_deposit(:deposit_info);
        let user = deposit_info.user;
        let amount = deposit_info.amount;

        let deposit_hash = deposit_hash(
            token_address: self.token_state.address,
            depositor: user.account.address,
            position_id: user.position_id,
            quantized_amount: amount,
            salt: deposit_info.salt,
        );

        assert_deposit_processed_event_with_expected(
            spied_event: self.event_info.get_next_event(contract_address: self.perpetuals_contract),
            position_id: user.position_id,
            depositing_address: user.account.address,
            quantized_amount: amount,
            deposit_request_hash: deposit_hash,
        );

        let status = IDepositDispatcher { contract_address: self.perpetuals_contract }
            .get_deposit_status(:deposit_hash);
        assert!(status == DepositStatus::PROCESSED, "Deposit not processed");
    }

    fn execute_process_deposit(ref self: FlowTestState, deposit_info: DepositInfo) {
        let operator_nonce = self.get_nonce();
        self.operator.set_as_caller(self.perpetuals_contract);

        IDepositDispatcher { contract_address: self.perpetuals_contract }
            .process_deposit(
                :operator_nonce,
                depositor: deposit_info.user.account.address,
                position_id: deposit_info.user.position_id,
                quantized_amount: deposit_info.amount.into(),
                salt: deposit_info.salt,
            );
    }

    fn deposit_and_process(ref self: FlowTestState, user: User, reciever: User, amount: u64) {
        let deposit_info = self.deposit(:user, :reciever, :amount);
        self.process_deposit(deposit_info);
    }

    fn self_deposit(ref self: FlowTestState, user: User, amount: u64) {
        self.deposit_and_process(:user, reciever: user, :amount);
    }

    fn withdraw_request(
        ref self: FlowTestState, user: User, recipient: User, amount: u128, expiration: Timestamp,
    ) -> WithdrawInfo {
        let salt = self.generate_salt();
        let recipient_address = recipient.account.address;
        let withdraw_args = WithdrawArgs {
            position_id: user.position_id,
            salt,
            expiration,
            collateral_id: constants::COLLATERAL_ASSET_ID(),
            amount: amount.try_into().unwrap(),
            recipient: recipient_address,
        };
        let msg_hash = withdraw_args.get_message_hash(public_key: user.account.key_pair.public_key);
        let signature = user.account.sign_message(message: msg_hash);

        user.account.set_as_caller(self.perpetuals_contract);
        ICoreDispatcher { contract_address: self.perpetuals_contract }
            .withdraw_request(
                signature,
                recipient: recipient_address,
                position_id: user.position_id,
                amount: amount.try_into().unwrap(),
                :expiration,
                :salt,
            );
        WithdrawInfo {
            user,
            recipient: recipient_address,
            amount: amount.try_into().unwrap(),
            expiration,
            salt,
        }
    }

    fn withdraw(ref self: FlowTestState, withdraw_info: WithdrawInfo) {
        let operator_nonce = self.get_nonce();
        self.operator.set_as_caller(self.perpetuals_contract);
        ICoreDispatcher { contract_address: self.perpetuals_contract }
            .withdraw(
                :operator_nonce,
                recipient: withdraw_info.recipient,
                position_id: withdraw_info.user.position_id,
                amount: withdraw_info.amount.try_into().unwrap(),
                expiration: withdraw_info.expiration,
                salt: withdraw_info.salt,
            );
    }

    fn request_and_withdraw(
        ref self: FlowTestState, user: User, recipient: User, amount: u128, expiration: Timestamp,
    ) {
        let withdraw_info = self.withdraw_request(:user, :recipient, :amount, :expiration);
        self.withdraw(withdraw_info);
    }

    fn self_withdraw(ref self: FlowTestState, user: User, amount: u128, expiration: Timestamp) {
        self.request_and_withdraw(:user, recipient: user, :amount, :expiration);
    }

    fn transfer_request(
        ref self: FlowTestState,
        user: User,
        recipient: PositionId,
        amount: u128,
        expiration: Timestamp,
    ) -> TransferInfo {
        let salt = self.generate_salt();
        let transfer_args = TransferArgs {
            position_id: user.position_id,
            salt,
            expiration,
            collateral_id: constants::COLLATERAL_ASSET_ID(),
            amount: amount.try_into().unwrap(),
            recipient,
        };
        let msg_hash = transfer_args.get_message_hash(public_key: user.account.key_pair.public_key);
        let signature = user.account.sign_message(message: msg_hash);

        user.account.set_as_caller(self.perpetuals_contract);
        ICoreDispatcher { contract_address: self.perpetuals_contract }
            .transfer_request(
                signature,
                :recipient,
                position_id: user.position_id,
                amount: amount.try_into().unwrap(),
                :expiration,
                :salt,
            );
        TransferInfo { user, recipient, amount: amount.try_into().unwrap(), expiration, salt }
    }

    fn transfer(ref self: FlowTestState, transfer_info: TransferInfo) {
        let operator_nonce = self.get_nonce();
        self.operator.set_as_caller(self.perpetuals_contract);
        ICoreDispatcher { contract_address: self.perpetuals_contract }
            .transfer(
                :operator_nonce,
                recipient: transfer_info.recipient,
                position_id: transfer_info.user.position_id,
                amount: transfer_info.amount,
                expiration: transfer_info.expiration,
                salt: transfer_info.salt,
            );
    }

    fn request_and_transfer(
        ref self: FlowTestState,
        user: User,
        recipient: PositionId,
        amount: u128,
        expiration: Timestamp,
    ) {
        let transfer_info = self.transfer_request(:user, :recipient, :amount, :expiration);
        self.transfer(transfer_info);
    }

    fn create_order(
        ref self: FlowTestState,
        user: User,
        base_amount: i64,
        base_asset_id: AssetId,
        quote_amount: i64,
        fee_amount: u64,
        expiration: Timestamp,
    ) -> Order {
        let salt = self.generate_salt();
        Order {
            position_id: user.position_id,
            base_asset_id,
            base_amount,
            quote_asset_id: constants::COLLATERAL_ASSET_ID(),
            quote_amount,
            fee_asset_id: constants::COLLATERAL_ASSET_ID(),
            fee_amount,
            expiration,
            salt,
        }
    }

    fn trade(
        ref self: FlowTestState,
        user_a: User,
        user_b: User,
        order_a: Order,
        order_b: Order,
        base: i64,
        quote: i64,
        fee: u64,
    ) {
        let operator_nonce = self.get_nonce();
        let signature_a = user_a
            .account
            .get_order_signature(order: order_a, public_key: user_a.account.key_pair.public_key);
        let signature_b = user_b
            .account
            .get_order_signature(order: order_b, public_key: user_b.account.key_pair.public_key);
        self.operator.set_as_caller(self.perpetuals_contract);

        ICoreDispatcher { contract_address: self.perpetuals_contract }
            .trade(
                :operator_nonce,
                :signature_a,
                :signature_b,
                :order_a,
                :order_b,
                actual_amount_base_a: base,
                actual_amount_quote_a: quote,
                actual_fee_a: fee,
                actual_fee_b: fee,
            );
    }

    fn liquidate(
        ref self: FlowTestState,
        liquidator_user: User,
        liquidated_user: User,
        liquidator_order: Order,
        liquidated_base: i64,
        liquidated_quote: i64,
        liquidated_fee: u64,
        liquidator_fee: u64,
    ) {
        let operator_nonce = self.get_nonce();
        let liquidator_signature = liquidator_user
            .account
            .get_order_signature(
                order: liquidator_order, public_key: liquidator_user.account.key_pair.public_key,
            );
        self.operator.set_as_caller(self.perpetuals_contract);

        ICoreDispatcher { contract_address: self.perpetuals_contract }
            .liquidate(
                :operator_nonce,
                :liquidator_signature,
                liquidated_position_id: liquidated_user.position_id,
                :liquidator_order,
                actual_amount_base_liquidated: liquidated_base,
                actual_amount_quote_liquidated: liquidated_quote,
                actual_liquidator_fee: liquidator_fee,
                liquidated_fee_amount: liquidated_fee,
            );
    }

    fn deleverage(
        ref self: FlowTestState,
        deleveraged_user: User,
        deleverager_user: User,
        deleveraged_base: i64,
        base_asset_id: AssetId,
        deleveraged_quote: i64,
    ) {
        let operator_nonce = self.get_nonce();
        self.operator.set_as_caller(self.perpetuals_contract);

        ICoreDispatcher { contract_address: self.perpetuals_contract }
            .deleverage(
                :operator_nonce,
                deleveraged_position_id: deleveraged_user.position_id,
                deleverager_position_id: deleverager_user.position_id,
                base_asset_id: base_asset_id,
                deleveraged_base_amount: deleveraged_base,
                deleveraged_quote_amount: deleveraged_quote,
            );
    }
    /// TODO: add all the necessary functions to interact with the contract.
}

pub fn advance_time(seconds: u64) {
    start_cheat_block_timestamp_global(Time::now().add(Time::seconds(seconds)).into());
}
