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
  part_number_sum := 0
  line_view := [dynamic]Line_Objects{}
  defer delete(line_view)

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

    found_horiz := find_horiz_nums_touching_syms(line_info_store)
    for num in found_horiz {
      part_number_sum += utils.string_to_int(num)
      delete_key(&line_info_store.numbers, num)
    }
    if !first_line {
      prev_line := pop(&line_view)
      curr_line := line_view[0]
      prev_line_nums := find_vert_nums_touching_syms(prev_line, curr_line)
      curr_line_nums := find_vert_nums_touching_syms(curr_line, prev_line)
      all_nums := utils.concat_slices(prev_line_nums, curr_line_nums)
      part_number_sum += slice.reduce(curr_line_nums, 0, proc(a:int, c:int) -> int { return a+c })
    }
  }
}

find_horiz_nums_touching_syms :: proc(line_objs: Line_Objects) -> (res: [dynamic]string) {
  for num, idx_arr in line_objs.numbers {
    i_arr := idx_arr[:]
    adj_left := slice.min(i_arr) - 1
    adj_right := slice.max(i_arr) + 1
    for sym, idx in line_objs.symbols {
      if adj_left == idx || adj_right == idx {
        append(&res, num)
      }
    }
  } 
  return
}

find_vert_nums_touching_syms :: proc(sym_line, num_line: Line_Objects) -> (res: [dynamic]string) {
  for sym, idx in sym_line.symbols {
    for num, idx_arr in num_line.numbers {
      i_arr := idx_arr[:]
      in_range := slice.contains(i_arr, idx) ||
                  slice.min(i_arr) - 1 == idx ||
                  slice.max(i_arr) + 1 == idx;
      if in_range {
        append(&res, num)
      }
    }
  }
  return
}
