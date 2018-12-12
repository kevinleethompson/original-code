use std::io::BufReader;
use std::io::BufRead;
use std::fs::File;

fn main() {
    let f = File::open("1dec_input.txt").unwrap();
    let base_modulations: Vec<i32> = BufReader::new(f).lines().map(|l| l.unwrap().parse::<i32>().unwrap()).collect();
    let first_cycle: Vec<(usize, i32)> = (&base_modulations).iter().by_ref().scan(0, |state, m| { *state = *state + m; Some(*state) }).enumerate().collect();
    let net_change_per_cycle: i32 = (&first_cycle)[first_cycle.len() - 1].1;
    println!("freq (part one): {}", &net_change_per_cycle);
    let mut cycle = (&first_cycle).iter().cloned().cycle();
    let mut curr_mod = 0;
    let mut cycle_num = 1;
    let found_repeat: i32 = 'outer: loop {
        let unwrapped = cycle.next().unwrap();
        if unwrapped.0 == first_cycle.len() - 1 { cycle_num += 1; }
        curr_mod = (net_change_per_cycle * cycle_num) + unwrapped.1;
        print!("{} ", curr_mod);
        let mut n = cycle_num - 1;
        while n >= 0 {
            let found = first_cycle.iter().by_ref().rev().find_map(|m| {
                let val = (net_change_per_cycle * n) + m.1;
                match val == &curr_mod { true => Some(val), false => None }
            });
            if let Some(x) = found { break 'outer x; }
            n = n - 1;
        }
    };
    println!("repeat (part two): {}", found_repeat);
}