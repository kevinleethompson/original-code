package utils

import "core:os"
import "core:strings"

/* Returns entire file contents as a string */
whole_file_as_string :: proc(path: string, alloc := context.allocator) -> string {
  data, ok := os.read_entire_file(path, alloc)
  if !ok {
    // do something
  }
  str_data := string(data)
  delete(data)
  return str_data
}
/* Check if a rune is numeric */
is_num :: proc(r: rune) -> bool {
  return ('0' <= r) && (r <= '9')
}
/* Check if a rune is alphabetic */
is_alpha :: proc(r: rune) -> bool {
  return ('a' <= r) && (r <= 'z') && ('A' <= r) && (r <= 'Z')
}
/* Converts a numeric rune into an integer */
rune_to_int :: proc(r: rune) -> int {
  return int(rune(u8(r) - '0'))
}
/* Converts a numeric string into an integer */
string_to_int :: proc(s: string) -> (result: int) {
  result = 0
  powers_10 := [8]int{1,10,100,1000,10000,100000,1000000,10000000}
  for r, idx in strings.reverse(s) {
    result += rune_to_int(r) * powers_10[idx] 
  }
  return
}
/* Combines all provided arrays into one */
concat_slices :: proc(slices: ..[]$T) -> (res: []$T) {
  res: []$T
  for s in slices {
    for item in s {
      append(&res, item)
    }
  }
  return
}
