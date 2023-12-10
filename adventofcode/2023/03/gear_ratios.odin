package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"
import "core:reflect"
import utils "../utils"

Num_Info :: struct {
  num_str: string,
  indexes: [dynamic]int
}

Gear_Info :: struct {
  idx: int,
  adj_nums: [dynamic]string
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

  gear_info_map := map[int][dynamic]Gear_Info{}
  gear_ratio_sum: u128 = 0

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
        if r == '*' {
          if i in gear_info_map {
            append(&gear_info_map[i], Gear_Info{ idx = idx, adj_nums = {} })
          } else {
            gear_info_map[i] = { Gear_Info{ idx = idx, adj_nums = {} } } }
          }
        line_info_store.symbols[idx] = r
      }
    }

    found_horiz := find_horiz_nums_touching_syms(line_info_store)
    for idx in found_horiz {
      part_number_sum += utils.string_to_int(line_info_store.numbers[idx].num_str)
    }
    if !first_line {
      prev_line := pop(&line_view)
      curr_line := line_info_store
      prev_line_nums := find_vert_nums_touching_syms(curr_line, prev_line)
      for idx in prev_line_nums {
        part_number_sum += utils.string_to_int(prev_line.numbers[idx].num_str)
      }
      curr_line_nums := find_vert_nums_touching_syms(prev_line, curr_line)
      for idx in curr_line_nums {
        part_number_sum += utils.string_to_int(curr_line.numbers[idx].num_str)
      }

      if i in gear_info_map {
        for g_info, g_idx in gear_info_map[i] {
          for idx, c_info in curr_line.numbers {
            if sym_is_adjacent(g_info.idx, c_info.indexes[:]) {
              append(&gear_info_map[i][g_idx].adj_nums, c_info.num_str)
            }
          }
          for idx, c_info in prev_line.numbers {
            if sym_is_adjacent(g_info.idx, c_info.indexes[:]) {
              append(&gear_info_map[i][g_idx].adj_nums, c_info.num_str)
            }
          }
        }
      }

      if i - 1 in gear_info_map {
        for g_info, g_idx in gear_info_map[i-1] {
          for idx, c_info in curr_line.numbers {
            if sym_is_adjacent(g_info.idx, c_info.indexes[:]) {
              append(&gear_info_map[i-1][g_idx].adj_nums, c_info.num_str)
            }
          }
          final_nums := gear_info_map[i-1][g_idx].adj_nums
          fmt.printf("final: %v\n", final_nums)
          if len(final_nums) == 2 {
            prod := utils.string_to_int(final_nums[0]) * utils.string_to_int(final_nums[1])
            gear_ratio_sum += u128(prod)
          }
        }
        delete_key(&gear_info_map, i - 1)
      }
    }
    first_line = false
    i += 1
    fmt.println(i)
    append(&line_view, line_info_store)
  }
  fmt.printf("Part Num Sum: %v\n", part_number_sum)
  fmt.printf("Gear Ratio Sum: %v\n", gear_ratio_sum)
}

sym_is_adjacent :: proc(sym_idx: int, idx_arr: []int) -> bool {
  return slice.contains(idx_arr, sym_idx) ||
         slice.min(idx_arr) - 1 == sym_idx ||
         slice.max(idx_arr) + 1 == sym_idx;
}

find_horiz_nums_touching_syms :: proc(line_objs: Line_Objects) -> (res: [dynamic]int) {
  for i, info in line_objs.numbers {
    i_arr := info.indexes[:]
    for idx, sym in line_objs.symbols {
      if sym_is_adjacent(idx, i_arr) {
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
      in_range := sym_is_adjacent(idx, i_arr)
      if in_range {
        append(&res, i)
      }
    }
  }
  return
}
