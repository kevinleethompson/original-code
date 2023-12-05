package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
  limits_map := map[string]int { "red" = 12, "green" = 13, "blue" = 14 }
  defer delete_map(limits_map)

  possible_games := 0

  data, ok := os.read_entire_file("../inputs/02_input.txt", context.allocator)
  if !ok { fmt.println("Could not read file") }
  defer delete(data, context.allocator)
  game_data := string(data)
  
  line_loop: for line in strings.split_lines_iterator(&game_data) {
    title_data_split := strings.split(line, ": ")
    game_label_split := strings.split(title_data_split[0], " ")
    game_number := string_to_int(game_label_split[1])
    game_rounds := strings.split(title_data_split[1], "; ")

    for round in game_rounds {
      round_draws := strings.split(round, ", ")
      for color_count in round_draws {
        color_count_split := strings.split(color_count, " ")
        num := string_to_int(color_count_split[0])
        color := color_count_split[1]
        if num > 14 || num > limits_map[color] {
          continue line_loop
        }
      }
    }
    possible_games += game_number
  }

  fmt.println(possible_games)
}

string_to_int :: proc(s: string) -> int {
  orders := [5]int {1, 10, 100, 1000, 10000}
  result := 0
  for r, idx in strings.reverse(s) {
    r_int := int(rune(u8(r) - '0'))
    result += r_int * orders[idx]
  }
  return result
}
