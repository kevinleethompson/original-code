use std::io::BufReader;
use std::io::BufRead;
use std::fs::File;

fn main() {
    let f = File::open("1dec_input.txt").unwrap();
    let base_modulations: Vec<i32> = BufReader::new(f).lines().map(|l| l.unwrap().parse::<i32>().unwrap()).collect();
    let first_cycle: Vec<i32> = (&base_modulations).iter().by_ref().scan(0, |state, m| { *state = *state + m; Some(*state) }).collect();
    let net_change_per_cycle: i32 = (&first_cycle)[first_cycle.len() - 1];
    println!("freq (part one): {}", &net_change_per_cycle);
    let mut cycle_num = 0;
    let found = base_modulations.iter()
                .scan(0, |state, m| { *state = *state + m; Some(*state) })
                .enumerate()
                .cycle()
                .find_map(|m| {
                    if m.0 == 0 { cycle_num += 1; }
                    let val = (net_change_per_cycle * cycle_num) + m.1;
                    match first_cycle.contains(&val) { true => Some(val), false => None }
                });
    println!("repeat (part two): {}", found.unwrap());
}