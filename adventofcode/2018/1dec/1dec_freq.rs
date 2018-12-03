use std::io::BufReader;
use std::io::BufRead;
use std::fs::File;

fn main() {
    let mut curr_freq = 0;
    let mut seen_freqs: Vec<i32> = Vec::new();
    let f = File::open("1dec_input.txt").unwrap();
    let modulations: Vec<(usize, i32)> = BufReader::new(f).lines().map(|l| l.unwrap().parse::<i32>().unwrap()).enumerate().collect();
    let mut mod_iter = modulations.iter().cloned().cycle();
    let mut idx = 1;
    let found_repeat = loop {
        let curr_mod = mod_iter.next().unwrap();
        curr_freq = curr_freq + curr_mod.1;
        if idx == modulations.len() - 1 {
            println!("freq (part one): {}", &curr_freq);
        } else if idx >= modulations.len() {
            if (&seen_freqs).contains(&curr_freq) {
                break curr_freq;
            }
        } else {
            idx = curr_mod.0;
        }
        idx += 1;
        seen_freqs.push(curr_freq);
    };
    println!("repeat (part two): {}", found_repeat);
}