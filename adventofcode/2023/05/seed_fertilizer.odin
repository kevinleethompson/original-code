package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:math"
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
  map_order: [dynamic]string
  mappings: map[string][dynamic]Conversion_Map
  defer delete(mappings)

  map_split := strings.split(str_data, "\n\n")
  for section, idx in map_split {
    if idx == 0 {
      seed_slice := strings.fields(strings.trim_prefix(section, "seeds: "))
      for seed in seed_slice {
        append(&seeds, u64(utils.string_to_int(seed)))
      }
    } else {
      name_nums_split := strings.split(section, " map:\n")
      mappings[name_nums_split[0]] = [dynamic]Conversion_Map{}
      append(&map_order, name_nums_split[0])
      s := section
      for line in strings.split_lines_iterator(&name_nums_split[1]) {
        dest_source_range_split := strings.fields(line)
        source := u64(utils.string_to_int(dest_source_range_split[1]))
        dest := u64(utils.string_to_int(dest_source_range_split[0]))
        range := u64(utils.string_to_int(dest_source_range_split[2]))
        append(&mappings[name_nums_split[0]], Conversion_Map{ source = source, dest = dest, range = range })
      }
    }
  }

  seed_to_end_dest_map: map[u64]u64

  for seed in seeds {
    current_source := seed
    current_dest: u64
    for name in map_order {
      for conv_map in mappings[name] {
        current_dest = convert_source_to_dest(current_source, conv_map)
        if current_dest != current_source { break }
      }
      current_source = current_dest
    }
    seed_to_end_dest_map[seed] = current_dest
  }
  
  fmt.println(seed_to_end_dest_map)
  vals, err := slice.map_values(seed_to_end_dest_map)
  fmt.println(slice.min(vals))
}

convert_source_to_dest :: proc(source: u64, conv_map: Conversion_Map) -> (res: u64) {
  end_range := conv_map.source + conv_map.range - 1
  dest_is_greater := conv_map.dest > conv_map.source
  difference := dest_is_greater ? conv_map.dest - conv_map.source : conv_map.source - conv_map.dest
  if (source >= conv_map.source) && (source <= end_range) {
    res = dest_is_greater ? source + difference : source - difference
  } else {
    res = source
  }
  return
}
