package main

import "core:os"
import "core:strings"
import "core:fmt"

num_word_map := map[string]int{ "one" = 1, "two" = 2, "three" = 3, "four" = 4, "five" = 5, "six" = 6, "seven" = 7, "eight" = 8, "nine" = 9 }

main :: proc() {
  sum := 0
  file_str := read_whole_file("../inputs/01_input.txt")
  for line in strings.split_lines_iterator(&file_str) {
    curr_num : int = -1
    line_len := len(line)
    first := strings.index_proc(line, is_num)
    last := strings.last_index_proc(line, is_num)
    first_int := int(u8(rune(line[first])) - '0')
    last_int :=  int(u8(rune(line[last])) - '0')
    sum += first_int * 10 + last_int
    //for c, idx in line {
    //  if !is_alpha(c) {
    //    if curr_num < 0 {
    //      curr_num = int(i8(c) - '0') 
    //      sum += curr_num * 10
    //    } else {
    //      curr_num = int(i8(c) - '0')
    //    }
    //  }
    //  if idx + 1 == line_len {
    //    sum += curr_num
    //  }
    //}
    if sum < 1000 {
      fmt.printf("line: %v, sum: %v\n", line, sum)
    }
  }
  fmt.println(sum)
}

read_whole_file :: proc(path: string) -> string {
  data, ok := os.read_entire_file(path, context.allocator)
  if !ok {
    fmt.println("Could not read file")
  }
  defer delete(data, context.allocator)

  string_data := string(data)
  return string_data
}

is_alpha :: proc(r: rune) -> bool {
  result := false
  switch r {
    case 'a'..='z','A'..='Z': result = true
  }
  return result
}

is_num :: proc(r: rune) -> bool {
  result := false
  switch r {
    case '0'..='9': result = true
  }
  return result
}
