package main

import "core:fmt"
import "core:os"
import "core:strings"
import utils "../utils"

main :: proc() {
  current_lines: [3]map[string]map[string][]int
  defer delete_map(current_lines)

  data, ok := os.read_entire_file("../inputs/03_input.txt")
  if !ok { fmt.println("Could not open file") }
  defer delete(data)

  input_str := string(data)
  for line in strings.split_lines_iterator(&input_str) {
    line_len := len(line)
    line_copy := strings.clone(line)
    for len(line_copy) > 1 {
      found_num := strings.index_proc(line_copy, utils.is_num)
      width := 1
      for utils.is_num(rune(line_copy[found_num + width])) { width += 1 }
    }
  }
}
