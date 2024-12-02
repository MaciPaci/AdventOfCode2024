import gleam/int
import gleam/list
import gleam/string as str
import gleam/result

pub fn parse_lines(input: String) -> List(String) {
  input
  |> str.split("\n")
  |> list.map(str.trim)
  |> list.filter(fn(x) { !str.is_empty(x)})
}

pub fn parse_numbers(input: String) -> List(Int) {
  input
  |> parse_lines
  |> list.map(fn(x) { int.parse(x) |> result.lazy_unwrap(fn() { panic }) })
}
