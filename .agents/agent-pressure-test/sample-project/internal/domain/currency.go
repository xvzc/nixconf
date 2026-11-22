package domain

type currencyInfo struct {
	// Increment is the smallest amount, in minor units, that a settlement total is
	// paid in. KRW settles in multiples of 10 won.
	Increment int64
	// MinFeeMinor is the smallest processing fee charged on a non-empty settlement.
	MinFeeMinor int64
}

var currencies = map[string]currencyInfo{
	"USD": {Increment: 1, MinFeeMinor: 30},
	"EUR": {Increment: 1, MinFeeMinor: 30},
	"JPY": {Increment: 1, MinFeeMinor: 30},
	"KRW": {Increment: 10, MinFeeMinor: 300},
	"KWD": {Increment: 5, MinFeeMinor: 100},
}

// Supported reports whether the ledger accepts the currency code.
func Supported(code string) bool {
	_, ok := currencies[code]
	return ok
}

// Increment returns the settlement rounding increment of a currency, in minor
// units. Unknown currencies use 1.
func Increment(code string) int64 {
	if c, ok := currencies[code]; ok {
		return c.Increment
	}
	return 1
}

// MinFee returns the minimum processing fee of a currency, in minor units.
func MinFee(code string) int64 {
	return currencies[code].MinFeeMinor
}
