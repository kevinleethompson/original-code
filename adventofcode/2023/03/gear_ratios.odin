package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"
import utils "../utils"

Line_Objects :: struct {
  symbols: map[rune]int,
  numbers: map[string][dynamic]int
}

main :: proc() {
  current_lines := []Line_Objects {
    Line_Objects{ symbols = {}, numbers = {} },
    Line_Objects{ symbols = {}, numbers = {} },
  }
  defer delete(current_lines)

  data, ok := os.read_entire_file("../inputs/03_input.txt")
  if !ok { fmt.println("Could not open file") }
  defer delete(data)

  first_line := true
  input_str := string(data)
  for line in strings.split_lines_iterator(&input_str) {
    num_is_contiguous_to_prev_found := false
    line_info_store := Line_Objects{ symbols = {}, numbers = {} }

    for r, idx in line {
      if r == '.' {
        num_is_contiguous_to_prev_found = false
        continue
      }
      found_num := utils.is_num(r)
      if found_num {
        if num_is_contiguous_to_prev_found { continue }
        num_is_contiguous_to_prev_found = true

        idx_arr := [dynamic]int{ idx }
        width := 1
        for utils.is_num(rune(line[idx + width])) {
          width += 1
          append(&idx_arr, idx + width)
        }
        num_substr, err : = strings.cut(line, idx, width)
        if err != nil { fmt.printf("Error: %v", err) }
        line_info_store.numbers[num_substr] = idx_arr
      } else {
        num_is_contiguous_to_prev_found = false
        line_info_store.symbols[r] = idx
      }
    }

    if !first_line {

    }
  }
}

is_less :: proc(first: int, next: int) -> bool { return first < next }