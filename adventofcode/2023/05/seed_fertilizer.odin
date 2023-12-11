package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"
import utils "../utils"


main :: proc() {
  data, ok := os.read_entire_file("../inputs/05_input.txt")
  if !ok { panic("Could not open file") }
  defer delete(data)
  str_data := string(data)

  map_split := strings.split(str_data, "\n\n")
  

}
