package domain

import "testing"

func TestCalculateFee(t *testing.T) {
	tests := []struct {
		name  string
		cur   string
		count int
		total int64
		want  int64
	}{
		{"no charges", "USD", 0, 0, 0},
		{"one charge", "USD", 1, 10_000, 290},
		{"ten charges", "USD", 10, 50_000, 1453},
		{"usd minimum", "USD", 1, 100, 30},
		{"krw minimum", "KRW", 1, 1_000, 300},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got := CalculateFee(DefaultSchedule, tc.cur, tc.count, tc.total)
			if got != tc.want {
				t.Errorf("CalculateFee = %d, want %d", got, tc.want)
			}
		})
	}
}

// 2.90% of 100.15 is 2.90435 and the per-entry part is 0.3, so the fee is 2.91.
// The two parts are added before rounding; rounding each part first gives 2.90.
func TestCalculateFeeRoundsPartsTogether(t *testing.T) {
	got := CalculateFee(DefaultSchedule, "USD", 1, 10_015)
	if got != 291 {
		t.Errorf("CalculateFee(10015) = %d, want 291", got)
	}
}
