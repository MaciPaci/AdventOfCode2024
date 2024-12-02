import gleam/dict.{type Dict}
import gleam/set
import gleam/result
import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  let input_list = parse_input(input)
  let two_lists = read_from_list(input_list, list.new(), list.new())
  let left = list.sort(two_lists.0, int.compare)
  let right = list.sort(two_lists.1, int.compare)
  list.zip(left, right) |> list.fold(0, fn(acc, el) {acc + int.absolute_value(el.0 - el.1)})
}

pub fn pt_2(input: String) {
  let input_list = parse_input(input)
  let two_lists = read_from_list(input_list, list.new(), list.new())
  let left = two_lists.0 |> set.from_list() |> set.to_list()
  let right = list.sort(two_lists.1, int.compare)
  let result = count_numbers(left, right, dict.new())
  result |> dict.fold(0, fn(acc, key, val) {acc + key * val})
}

fn parse_input(input:String) -> List(List(Int)) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(s) {
    string.split(s, " ")
    |> list.filter(fn(el) { !string.is_empty(el) })
    |> list.map(fn(el) {int.parse(el) |> result.unwrap(0)})
  })
}

fn read_from_list(list: List(List(Int)), left: List(Int), right: List(Int)) -> #(List(Int), List(Int)) {
  case list {
    [first, ..rest] -> {
      case first {
        [a, b] -> read_from_list(rest, list.append(left, [a]), list.append(right, [b]))
        _ -> #(left, right)
      }
    }
    _ -> #(left, right)
  }
}

fn count_numbers(left: List(Int), right: List(Int), result: Dict(Int, Int)) -> Dict(Int, Int) {
  case list.pop(left, fn(_) {True}) {
    Ok(#(el, rest)) -> {
      let count = list.count(right, fn(r) {r == el})
      let current_count = dict.get(result, el) |> result.unwrap(0)
      count_numbers(rest, right, dict.insert(result, el, current_count+count))
    }
    Error(_) -> result
  }
}
