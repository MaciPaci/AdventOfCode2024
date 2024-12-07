import gleam/int
import gleam/result
import gleam/list
import gleam/string
import utils/tuple
import utils/lister

pub fn parse(input: String) -> List(#(Int, List(Int))) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(answer, inputs)) = line |> string.split_once(":")
    let assert Ok(answer) = answer |> string.trim |> int.parse
    #(
    answer,
    inputs |> string.trim |> string.split(" ") |> list.filter_map(int.parse),
    )
  })
}

pub fn pt_1(input: List(#(Int, List(Int)))) {
  input
  |> list.filter(solve_equation)
  |> list.map(tuple.first)
  |> lister.sum
}

fn solve_equation(record: #(Int, List(Int))) -> Bool {
  case record.1 {
    [] -> False
    [acc, ..rest] -> solve_combinations(record.0, acc, rest)
  }
}

fn solve_combinations(result: Int, acc: Int, parameters: List(Int)) -> Bool {
  case parameters {
    [] -> acc == result
    [next, ..rest] ->
      acc <= result
      && {
        solve_combinations(result, acc * next, rest)
        || solve_combinations(result, acc + next, rest)
      }
  }
}

pub fn pt_2(input: List(#(Int, List(Int)))) {
  input
  |> list.filter(solve_equation_pt2)
  |> list.map(tuple.first)
  |> lister.sum
}

fn solve_equation_pt2(record: #(Int, List(Int))) -> Bool {
  case record.1 {
    [] -> False
    [acc, ..rest] -> solve_combinations_pt2(record.0, acc, rest)
  }
}

fn solve_combinations_pt2(result: Int, acc: Int, parameters: List(Int)) -> Bool {
  case parameters {
    [] -> acc == result
    [next, ..rest] ->
    acc <= result
    && {
      solve_combinations_pt2(result, acc * next, rest)
      || solve_combinations_pt2(result, acc + next, rest)
      || solve_combinations_pt2(result, concat_numbers(acc, next), rest)
    }
  }
}

fn concat_numbers(acc: Int, next: Int) -> Int {
  int.parse(int.to_string(acc) <> int.to_string(next)) |> result.unwrap(0)
}
