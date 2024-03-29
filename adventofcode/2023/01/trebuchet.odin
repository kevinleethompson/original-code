package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:slice"
import utils "../utils"

main :: proc() {
  num_word_map := map[string]int{ "one" = 1, "two" = 2, "three" = 3, "four" = 4, "five" = 5, "six" = 6, "seven" = 7, "eight" = 8, "nine" = 9 }
  defer delete_map(num_word_map)
  
  num_words, err := slice.map_keys(num_word_map)
  defer delete_slice(num_words, context.allocator)

  sum := 0
  data, ok := os.read_entire_file("../inputs/01_input.txt", context.allocator)
  if !ok {
    fmt.println("Could not read file")
  }
  defer delete(data, context.allocator)

  string_data := string(data)
  file_str := string_data

  for line in strings.split_lines_iterator(&file_str) {
    if sum < 500 { fmt.println(line) }
    first_num_i := strings.index_proc(line, utils.is_num)
    last_num_i := strings.last_index_proc(line, utils.is_num)
    first_int := utils.rune_to_int(rune(line[first_num_i]))
    last_int :=  utils.rune_to_int(rune(line[last_num_i]))
    
    line_remainder := strings.cut(line, last_num_i)

    first_word: string
    first_word_i, first_word_len := strings.index_multi(line, num_words)
    last_word_i, last_word := find_last_substr_multi(line_remainder, num_words)

    if first_word_i >= 0 {
      first_word = strings.cut(line, first_word_i, first_word_len)
      first_int = first_num_i < first_word_i ? first_int : num_word_map[first_word]
    }
    if last_word_i >= 0 {
      last_int = num_word_map[last_word]
    }

    sum += first_int * 10 + last_int
    if sum < 1000 {
      fmt.printf("line: %v, sum: %v, fw: %v, lw %v\n", line, sum, first_word, last_word)
    }
  }

  fmt.println(sum)
}

find_last_substr_multi :: proc(s: string, substrs: []string) -> (int, string) {
  input_s := s
  slice.reverse_sort(substrs)
  min_word_len := len(substrs[0])

  for len(input_s) >= min_word_len {
    for str in substrs {
      if strings.has_suffix(input_s, str) {
        found_idx := len(s) - len(str)
        return found_idx, str
      }
    }
    input_s = strings.cut(input_s, 0, len(input_s) - 1)
  }

  return -1, ""
}
