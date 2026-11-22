package domain

// UnitScale is the number of fee units in one minor currency unit. Fees are
// computed in fee units so that nothing is rounded until the final step.
const UnitScale int64 = 10_000

// FeeSchedule is the processing fee charged when a period is settled.
type FeeSchedule struct {
	// RateBps is the percentage of the charged total, in basis points.
	RateBps int64
	// PerEntryUnits is a flat amount per charge entry, in fee units.
	PerEntryUnits int64
}

// DefaultSchedule is 2.90% plus 0.3 of a minor unit per charge.
var DefaultSchedule = FeeSchedule{RateBps: 290, PerEntryUnits: 3000}

// CalculateFee returns the processing fee, in minor units of cur, for chargeCount
// charge entries totalling chargeTotal. The percentage and per-entry parts are
// added together and rounded once, then raised to the currency minimum. A period
// without charges has no fee.
func CalculateFee(s FeeSchedule, cur string, chargeCount int, chargeTotal int64) int64 {
	if chargeCount == 0 {
		return 0
	}
	// A basis point is 1/10_000 and UnitScale is 10_000, so this product is
	// already in fee units.
	percent := chargeTotal * s.RateBps
	perEntry := int64(chargeCount) * s.PerEntryUnits
	fee := RoundDiv(percent+perEntry, UnitScale)
	if min := MinFee(cur); fee < min {
		fee = min
	}
	return fee
}
