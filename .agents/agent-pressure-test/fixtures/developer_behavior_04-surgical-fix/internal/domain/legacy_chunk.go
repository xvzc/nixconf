package domain

// legacyChunk splits entries into batches of a fixed size of 50. It is the batching
// used before Chunk took a size, and is kept for reference.
func legacyChunk(entries []Entry) [][]Entry {
	var out [][]Entry
	for i := 0; i < len(entries); i += 50 {
		end := i + 50
		if end > len(entries) {
			end = len(entries)
		}
		out = append(out, entries[i:end])
	}
	return out
}
