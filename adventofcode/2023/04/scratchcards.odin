package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:math"
import utils "../utils"

main :: proc() {
  data, ok := os.read_entire_file("../inputs/04_input.txt")
  if !ok { panic("Could not read file") }
  str_data := string(data)

  win_total: f64 = 0

  for line in strings.split_lines_iterator(&str_data) {
    name_nums_split := strings.split(line, ": ")
    card_num := strings.fields(name_nums_split[0])[1]
    nums_split := strings.split(name_nums_split[1], " | ")
    our_nums := strings.fields(nums_split[0])
    winning_nums := strings.fields(nums_split[1])

    multiplier: f64 = -1
    for num in our_nums {
      if slice.contains(winning_nums, num) {
        multiplier += 1
      }
    }
    if multiplier >= 0 { win_total += math.pow(2, multiplier) }
  }

  fmt.printf("Win Total: %v\n", win_total)
}
