package domain

// RoundDiv divides n by d (d > 0) and rounds half away from zero.
func RoundDiv(n, d int64) int64 {
	if n >= 0 {
		return (n + d/2) / d
	}
	return -((-n + d/2) / d)
}

// RoundToIncrement rounds amount to the nearest multiple of inc, half away from
// zero. An increment of 1 or less leaves the amount unchanged.
func RoundToIncrement(amount, inc int64) int64 {
	if inc <= 1 {
		return amount
	}
	return RoundDiv(amount, inc) * inc
}
