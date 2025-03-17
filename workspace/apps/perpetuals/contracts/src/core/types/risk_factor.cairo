use core::num::traits::zero::Zero;

// Fixed-point decimal with 2 decimal places.
//
// Example: 0.75 is represented as 75.
#[derive(Copy, Debug, Default, Drop, PartialEq, Serde, starknet::Store)]
pub struct RiskFactor {
    value: u8 // Stores number * 100
}

const DENOMINATOR: u8 = 100_u8;

#[generate_trait]
pub impl RiskFactorImpl of RiskFactorTrait {
    fn new(value: u8) -> RiskFactor {
        assert(value <= DENOMINATOR, 'Value must be <= 100');
        RiskFactor { value }
    }

    /// Multiplies the fixed-point value by `other` and divides by DENOMINATOR.
    /// Integer division truncates toward zero to the nearest integer.
    ///
    /// Example: RiskFactorTrait::new(75).mul(300) == 225
    /// Example: RiskFactorTrait::new(75).mul(301) == 225
    /// Example: RiskFactorTrait::new(75).mul(-5) == -3
    fn mul(self: @RiskFactor, other: u128) -> u128 {
        ((*self.value).into() * other) / DENOMINATOR.into()
    }
}

impl RiskFactorZero of core::num::traits::Zero<RiskFactor> {
    fn zero() -> RiskFactor {
        RiskFactor { value: 0 }
    }
    fn is_zero(self: @RiskFactor) -> bool {
        self.value.is_zero()
    }
    fn is_non_zero(self: @RiskFactor) -> bool {
        self.value.is_non_zero()
    }
}


#[cfg(test)]
mod tests {
    use core::num::traits::zero::Zero;
    use super::{RiskFactor, RiskFactorTrait};

    #[test]
    fn test_new() {
        let d = RiskFactorTrait::new(75);
        assert_eq!(d.value, 75);
    }

    #[test]
    #[should_panic(expected: 'Value must be <= 100')]
    fn test_new_invalid_max() {
        RiskFactorTrait::new(101);
    }

    #[test]
    fn test_zero() {
        let d: RiskFactor = Zero::zero();
        assert_eq!(d.value, 0);
    }
    #[test]
    fn test_is_zero() {
        let d: RiskFactor = Zero::zero();
        assert!(d.is_zero());
        assert!(!d.is_non_zero());
    }
    #[test]
    fn test_is_non_zero() {
        let d: RiskFactor = RiskFactorTrait::new(1);
        assert!(d.is_non_zero());
        assert!(!d.is_zero());
    }

    #[test]
    fn test_mul() {
        assert_eq!(RiskFactorTrait::new(75).mul(300_u128), 225);
        assert_eq!(RiskFactorTrait::new(75).mul(301_u128), 225);
        assert_eq!(RiskFactorTrait::new(75).mul(299_u128), 224);
    }
}
