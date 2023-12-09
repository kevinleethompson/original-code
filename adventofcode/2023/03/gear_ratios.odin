package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"
import utils "../utils"

Num_Info :: struct {
  num_str: string,
  indexes: [dynamic]int
}

Line_Objects :: struct {
  symbols: map[int]rune,
  numbers: map[int]Num_Info
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
  i := 0
  for line in strings.split_lines_iterator(&input_str) {
    num_is_contiguous_to_prev_found := false
    line_info_store := Line_Objects{ symbols = {}, numbers = {}}

    for r, idx in line {
      if r == '.' {
        num_is_contiguous_to_prev_found = false
        continue
      }
      found_num := utils.is_num(r)
      if found_num {
        if num_is_contiguous_to_prev_found { continue }
        num_is_contiguous_to_prev_found = true

        info := Num_Info { num_str = "", indexes = [dynamic]int{ idx } }
        width := 1
        for idx + width <= 139 && utils.is_num(rune(line[idx + width])) {
          append(&info.indexes, idx + width)
          width += 1
        }
        num_substr, err : = strings.cut(line, idx, width)
        if err != nil { fmt.printf("Error: %v", err) }
        info.num_str = num_substr
        line_info_store.numbers[idx] = info
      } else {
        num_is_contiguous_to_prev_found = false
        line_info_store.symbols[idx] = r
      }
    }
    i += 1

    found_horiz := find_horiz_nums_touching_syms(line_info_store)
    for idx in found_horiz {
      part_number_sum += utils.string_to_int(line_info_store.numbers[idx].num_str)
      delete_key(&line_info_store.numbers, idx)
    }
    if !first_line {
      prev_line := pop(&line_view)
      curr_line := line_info_store
      prev_line_nums := find_vert_nums_touching_syms(curr_line, prev_line)
      for idx in prev_line_nums {
        part_number_sum += utils.string_to_int(prev_line.numbers[idx].num_str)
        delete_key(&prev_line.numbers, idx)
      }
      curr_line_nums := find_vert_nums_touching_syms(prev_line, curr_line)
      for idx in curr_line_nums {
        part_number_sum += utils.string_to_int(curr_line.numbers[idx].num_str)
        delete_key(&curr_line.numbers, idx)
      }
    }
    first_line = false
    append(&line_view, line_info_store)
  }
  fmt.printf("Part Num Sum: %v\n", part_number_sum)
}

find_horiz_nums_touching_syms :: proc(line_objs: Line_Objects) -> (res: [dynamic]int) {
  for i, info in line_objs.numbers {
    i_arr := info.indexes[:]
    adj_left := slice.min(i_arr) - 1
    adj_right := slice.max(i_arr) + 1
    for idx, sym in line_objs.symbols {
      if adj_left == idx || adj_right == idx {
        append(&res, i)
      }
    }
  } 
  return
}

find_vert_nums_touching_syms :: proc(sym_line, num_line: Line_Objects) -> (res: [dynamic]int) {
  for idx, sym in sym_line.symbols {
    for i, info in num_line.numbers {
      i_arr := info.indexes[:]
      in_range := slice.contains(i_arr, idx) ||
                  slice.min(i_arr) - 1 == idx ||
                  slice.max(i_arr) + 1 == idx;
      if in_range {
        append(&res, i)
      }
    }
  }
  return
}
