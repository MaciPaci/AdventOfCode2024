import utils/lister
import gleam/result
import gleam/int
import gleam/list
import gleam/string
import gleam/dict.{type Dict}

type Memory = Dict(Int, Int)

pub fn pt_1(input: String) {
  let stones = input |> string.split(" ") |> list.map(fn(el) { int.parse(el) |> result.unwrap(-1)})
  stones
  |> list.fold(dict.new(), fn(mem, el) {
    dict.insert(mem, el, 1 + {dict.get(mem, el) |> result.unwrap(0)})
  })
  |> blink_n_times(25)
  |> dict.values
  |> lister.sum
}

pub fn pt_2(input: String) {
  let stones = input |> string.split(" ") |> list.map(fn(el) { int.parse(el) |> result.unwrap(-1)})
  stones
  |> list.fold(dict.new(), fn(mem, el) {
    dict.insert(mem, el, 1 + {dict.get(mem, el) |> result.unwrap(0)})
  })
  |> blink_n_times(75)
  |> dict.values
  |> lister.sum
}

fn blink_n_times(mem: Memory, n: Int) -> Memory {
  case n {
    0 -> mem
    _ -> blink_n_times(blink_for_stones(dict.to_list(mem), mem), n - 1)
  }
}

fn blink_for_stones(stones: List(#(Int, Int)), mem: Memory) -> Memory {
  case stones {
    [] -> mem
    [stone, ..rest] -> blink_for_stones(rest, blink(stone, mem))
  }
}

fn blink(stone: #(Int, Int), mem: Memory) -> Memory {
  let #(stone, count) = stone
  let count_old = dict.get(mem, stone) |> result.unwrap(0)
  case count_old {
    0 -> mem
    _ -> {
      case stone {
        0 -> {
          let count_of_1 = dict.get(mem, 1) |> result.unwrap(0)

          dict.insert(mem, 0, count_old - 1 * count)
          |> dict.insert(1, count_of_1 + 1 * count)
        }
        _ -> {
          case has_even_number_of_digits(stone) {
            #(True, #(left, right)) -> {
              let count_left = dict.get(mem, left) |> result.unwrap(0)
              let d_left = dict.insert(mem, stone, count_old - 1 * count)
              |> dict.insert(left, count_left + 1 * count)

              let count_right = dict.get(d_left, right) |> result.unwrap(0)
              dict.insert(d_left, right, count_right + 1 * count)
            }
            #(False, _) -> {
              let new_val = stone * 2024
              let count_new = dict.get(mem, new_val) |> result.unwrap(0)
              dict.insert(mem, stone, count_old - 1 * count)
              |> dict.insert(new_val, count_new + 1 * count)
            }
          }
        }
      }
    }
  }
}

fn has_even_number_of_digits(number: Int) -> #(Bool, #(Int, Int)) {
  let number_str = number |> int.to_string |> string.to_graphemes
  let #(left, right) = number_str |> list.split(list.length(number_str) / 2)
  let left_int = list.fold(left, "", fn(acc, el) {acc <> el}) |> int.parse |> result.unwrap(-1)
  let right_int = list.fold(right, "", fn(acc, el) {acc <> el}) |> int.parse |> result.unwrap(-1)
  #(list.length(number_str) % 2 == 0, #(left_int, right_int))
}
