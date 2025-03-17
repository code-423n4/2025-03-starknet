use perpetuals::core::types::position::{PositionData, PositionId};
use perpetuals::core::value_risk_calculator::PositionTVTR;
use starknet::ContractAddress;
use starkware_utils::types::time::time::Timestamp;
use starkware_utils::types::{PublicKey, Signature};

#[starknet::interface]
pub trait IPositions<TContractState> {
    fn get_position_assets(self: @TContractState, position_id: PositionId) -> PositionData;
    fn get_position_tv_tr(self: @TContractState, position_id: PositionId) -> PositionTVTR;
    fn is_deleveragable(self: @TContractState, position_id: PositionId) -> bool;
    fn is_healthy(self: @TContractState, position_id: PositionId) -> bool;
    fn is_liquidatable(self: @TContractState, position_id: PositionId) -> bool;
    // Position Flows
    fn new_position(
        ref self: TContractState,
        operator_nonce: u64,
        position_id: PositionId,
        owner_public_key: PublicKey,
        owner_account: ContractAddress,
    );
    fn set_owner_account_request(
        ref self: TContractState,
        signature: Signature,
        position_id: PositionId,
        new_owner_account: ContractAddress,
        expiration: Timestamp,
    );
    fn set_owner_account(
        ref self: TContractState,
        operator_nonce: u64,
        position_id: PositionId,
        new_owner_account: ContractAddress,
        expiration: Timestamp,
    );
    fn set_public_key_request(
        ref self: TContractState,
        signature: Signature,
        position_id: PositionId,
        new_public_key: PublicKey,
        expiration: Timestamp,
    );
    fn set_public_key(
        ref self: TContractState,
        operator_nonce: u64,
        position_id: PositionId,
        new_public_key: PublicKey,
        expiration: Timestamp,
    );
}
