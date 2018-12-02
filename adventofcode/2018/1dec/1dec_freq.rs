use std::io::BufReader;
use std::io::BufRead;
use std::fs::File;

fn main() {
    let mut freq = 0;
    let f = File::open("dec1_input.txt").unwrap();
    let file = BufReader::new(&f);
    for (_, line) in file.lines().enumerate() {
        let l = line.unwrap();
        let val = &l[1..].parse::<i32>().unwrap();
        match &l[..1] {
            "+" => freq += val,
            "-" => freq -= val,
            _ => panic!("data is messed up somehow")
        }
    }
    print!("{}", freq);
}
