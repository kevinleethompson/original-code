package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:math"
import utils "../utils"

Card_Info :: struct {
  match_count: int,
  won_cards: [dynamic]int  
}

main :: proc() {
  data, ok := os.read_entire_file("../inputs/04_input.txt")
  if !ok { panic("Could not read file") }
  str_data := string(data)
  defer delete(data)

  win_total := 0
  cards_total := 0
  cards_map: map[int]Card_Info
  defer delete(cards_map)

  for line in strings.split_lines_iterator(&str_data) {
    name_nums_split := strings.split(line, ": ")
    card_num := utils.string_to_int(strings.fields(name_nums_split[0])[1])
    nums_split := strings.split(name_nums_split[1], " | ")
    our_nums := strings.fields(nums_split[0])
    winning_nums := strings.fields(nums_split[1])

    cards_map[card_num] = Card_Info{ match_count = 0, won_cards = {} }

    multiplier := -1
    for num in our_nums {
      if slice.contains(winning_nums, num) {
        multiplier += 1
      }
    }

    won_cards := [dynamic]int{}
    if multiplier >= 0 {
      win_total += int(math.pow(2, f64(multiplier)))
      for i in 1..=(int(multiplier) + 1) {
        append(&won_cards, card_num + i)
      }
    }
    cards_map[card_num] = Card_Info{ match_count = int(multiplier+1), won_cards = won_cards }
  }

  for card_num, info in cards_map {
    cards_total += 1
    if len(info.won_cards) > 0 {
      cards_total += recursively_count_all_cards(&cards_map, info)
    }
  }

  fmt.printf("Win Total: %v\n", win_total)
  fmt.printf("Cards Total: %v\n", cards_total)
}

recursively_count_all_cards :: proc(card_map: ^map[int]Card_Info, info: Card_Info) -> (res: int) {
  res = 0
  for card in info.won_cards {
    c_info := card_map[card]
    res += 1 + recursively_count_all_cards(card_map, c_info)
  }
  return
}
