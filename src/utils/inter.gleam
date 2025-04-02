import gleam/result
import gleam/int

pub fn from_string(input: String) -> Int {
  input
  |> int.parse
  |> result.unwrap(0)
}
