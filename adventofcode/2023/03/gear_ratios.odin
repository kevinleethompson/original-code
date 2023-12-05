package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
  data, ok := os.read_entire_file("../inputs/03_input.txt")
  if !ok { fmt.println("Could not open file") }
  defer delete(data)

  input_str := string(data)
  for line in strings.split_lines_iterator(&input_str) {

  }
}

string_to_int :: proc(s: string) -> (result: int) {
  result := 0
  orders := [5]int{1,10,100,1000,10000}
  for r, idx in strings.reverse(s) {
    r_int := int(rune(u8(r) - '0'))
    result += r_int * orders[idx]
  }
  return
}
