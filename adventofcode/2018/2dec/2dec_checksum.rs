use std::io::BufReader;
use std::io::BufRead;
use std::fs::File;

fn main() {
	let mut two_sum = 0;	
	let mut three_sum = 0;	
    let f = File::open("2dec_input.txt").unwrap();
    let codes: Vec<String> = BufReader::new(f).lines().map(|l| l.unwrap()).collect();
	(&codes).into_iter().for_each(|code| {
		let mut has_two = false;
		let mut has_three = false;
		for c in (&code).char_indices() {
			if has_two && has_three { break; }
			match code.matches(c.1).collect::<String>().len() {
				2 => { if !has_two { two_sum += 1; has_two = true; } },
				3 => { if !has_three { three_sum += 1; has_three = true; } },
				_ => continue
			};
		}
		if let Some(found_near_match) = (&codes).into_iter().find(|x| match_substrings_exact(x, &code).join("").len() == (&code).len() - 1) {
			println!("code: {}", &code);
			println!("found: {}", match_substrings_exact(found_near_match, &code).join(""));
		}
	});

	println!("two: {}, three: {}, check: {}", two_sum, three_sum, two_sum * three_sum);
}

fn match_substrings_exact(s1: &String, s2: &String) -> Vec<String> {
	let mut matches: Vec<String> = vec![];
	let mut s2_chars = (*s2).chars();
	for c in (*s1).char_indices() {
		let s2_char = s2_chars.nth(0);
		match s2_char {
			Some(x) => {
				if x == c.1 {
					let mut match_str = String::new();
					if let Some(last_str) = matches.pop() {
						match_str = last_str + &c.1.to_string();
					} else {
						match_str = c.1.to_string();
					};
					matches.push(match_str);
				} else {
					let mut append_new = false;
					match matches.last() {
						Some(m) => {
							if m.len() > 0 && c.0 < (*s1).len() - 1 {
								append_new = true;
							}
						},
						_ => continue
					};
					if append_new { matches.push(String::new()); }
				}
			},
			None => break
		};
	}
	matches
}