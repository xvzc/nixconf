package domain

import "testing"

func TestRoundDiv(t *testing.T) {
	tests := []struct{ n, d, want int64 }{
		{0, 10000, 0},
		{20000, 10000, 2},
		{-30000, 10000, -3},
		{-15000, 10000, -2},
		{-14999, 10000, -1},
		{-6000, 10000, -1},
	}
	for _, tc := range tests {
		if got := RoundDiv(tc.n, tc.d); got != tc.want {
			t.Errorf("RoundDiv(%d, %d) = %d, want %d", tc.n, tc.d, got, tc.want)
		}
	}
}

func TestRoundToIncrement(t *testing.T) {
	tests := []struct{ amount, inc, want int64 }{
		{1234, 1, 1234},
		{1230, 10, 1230},
		{1234, 10, 1230},
		{-1235, 10, -1240},
		{0, 5, 0},
		{-7, 5, -5},
	}
	for _, tc := range tests {
		if got := RoundToIncrement(tc.amount, tc.inc); got != tc.want {
			t.Errorf("RoundToIncrement(%d, %d) = %d, want %d", tc.amount, tc.inc, got, tc.want)
		}
	}
}

func TestIncrementPerCurrency(t *testing.T) {
	if Increment("USD") != 1 || Increment("KRW") != 10 || Increment("KWD") != 5 {
		t.Error("unexpected currency increments")
	}
}
