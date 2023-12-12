package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"
import utils "../utils"

Conversion_Map :: struct {
  source: u64,
  dest: u64,
  range: u64
}

main :: proc() {
  data, ok := os.read_entire_file("../inputs/05_input.txt")
  if !ok { panic("Could not open file") }
  defer delete(data)
  str_data := string(data)

  seeds: [dynamic]u64
  mappings: map[string][dynamic]Conversion_Map
  defer delete(mappings)

  map_split := strings.split(str_data, "\n\n")
  for section, idx in map_split {
    fmt.printf("idx: %v, section: %v\n", idx, section)
    if idx == 0 {
      seed_slice := strings.fields(strings.trim_prefix(section, "seeds: "))
      for seed in seed_slice {
        //fmt.println(seed)
        append(&seeds, u64(utils.string_to_int(seed)))
      }
    } else {
      //fmt.println(section)
      name_nums_split := strings.split(section, " map:\n")
      mappings[name_nums_split[0]] = [dynamic]Conversion_Map{}
      s := section
      for line in strings.split_lines_iterator(&s) {
        dest_source_range_split := strings.fields(line)
        source := u64(utils.string_to_int(dest_source_range_split[1]))
        dest := u64(utils.string_to_int(dest_source_range_split[0]))
        range := u64(utils.string_to_int(dest_source_range_split[2]))
        append(&mappings[name_nums_split[0]], Conversion_Map{ source = source, dest = dest, range = range })
      }
    }
  }
  
  fmt.println(mappings)

}
