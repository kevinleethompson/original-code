# sillynames

## About

This program mutates a normal personal name into a silly sounding version.
	(Ex: "Kevin Thompson" may become "Kifin Tompsan" or "Quevil Thankson")

 The program takes an input personal name given as space-delimited strings. It first runs checks to ensure the provided strings
are likely to be actual names (and not random letter combos or non-alpha chars), then uses the wordparts JSON to break
out the names into its significant letter combos.

`Ex: "Chundrick" -> ["ch", "u", "nd", "r", "i", "ck"])`


The parts are then mutated individually and joined back together to form the sillified name.

`Ex: ["ch", "u", "nd", "r", "i", "ck"] -> ["ch", "u", "mp", "l", "e", "rk"] -> "Chumplerk"`

The mutation is performed in a very dumb way but is sufficient to produce the desired result. The wordparts dictionary contains
'vowel' and 'consonant' dictionaries which contain the corresponding letter combos mapped to dicts with three keys: `'mutations' ->
a list of suitable letter combos to mutate to`, `'adj_l' and 'adj_r' -> the numeric codes denoting which class of letter can be adjacent
this one on the left and right sides, respectively` (See 'Wordparts Dictionary Excerpt' and 'Adjacency Rules Codes' below). These
hard-coded data ensure that the names are mutated in a sensible way by replacing the original parts with those having similar sounds
and by avoiding unusual or invalid letter combinations. Including many common 2-3 letter combinations in the wordparts dict helps
significantly to produce natural sound combinations. For example, if we treat the "nd" in "Chundrick" as the separate letters "n" and
"d", we may get back the mutations "m" and "t." These mutations are fine on their own, but after joining back together they would form
the unnatural combination "mt", producing the awkward name "Chumtlerk" instead of "Chumplerk."


Randomized shuffling of possible mutation targets and occassional "two-hop" mutations (mutating an already mutated part) are done
to give results a higher rate of variation. However, the algorithm also ensures that not every word part gets mutated so that the
result is still recognizable as a variation of the original name and not something entirely different.


## How to Use

Inside the folder containing <b>sillyname.py</b> and <b>wordparts.json</b>:

```bash
python sillyname.py Kevin Thompson  # or whatever name
```

---

### Wordparts Dictionary Excerpt:
```python
{
	"vowel": {
		"a": {"mutations": ["a", "o", "u"], "adj_l": 3, "adj_r": 3},
		"ai": {"mutations": ["a", "ai", "e", "ei", "y"], "adj_l": 1, "adj_r": 1},
		...
	},
	"consonant": {
		"b": {"mutations": ["d", "p"], "adj_l": 3, "adj_r": 3},
		"bb": {"mutations": ["b", "d", "dd", "p", "pp"], "adj_l": 30, "adj_r": 3},
		...
	}
}
```


### Adjacency Rules Codes:
```
	0 - start/end only
	1 - consonant only
	2 - vowel only
	3 - any
	10 - consonant only, cannot be at start/end
	20 - vowel only, cannot be at start/end
	30 - any, cannot be at start/end
```
