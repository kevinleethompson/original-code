package main

import "core:os"
import "core:strings"
import "core:fmt"

main :: proc() {
  sum := 0
  file_str := read_whole_file("../inputs/01_input.txt")
  for line in strings.split_lines_iterator(file_str) {
    fmt.println(line)
    curr_num : int = -1
    line_len := len(line)
    for c, idx in line {
      if !is_alpha(c) {
        if curr_num < 0 {
          curr_num = int(c)
          sum += curr_num
        } else {
          curr_num = int(c)
        }
        if idx + 1 == line_len {
          sum += curr_num
        }
      }
    }
  }
  fmt.println(sum)
}

read_whole_file :: proc(path: string) -> ^string {
  data, ok := os.read_entire_file(path, context.allocator)
  if !ok {
    fmt.println("Could not read file")
    return nil
  }
  defer delete(data, context.allocator)

  string_data := string(data)
  return &string_data
}

is_alpha :: proc(r: rune) -> bool {
  result := false
  switch r {
    case 'a'..='z','A'..='Z': result = true
  }
  return result
}
