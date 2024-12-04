import gleam/result
import gleam/int
import gleam/list
import gleam/string
import gleam/regexp.{type Match}

pub fn pt_1(input: String) {
  let matches = find_matches_for_string(input)
  execute_instructions(matches, 0)
}

fn find_matches_for_string(input: String) -> List(Match) {
  let assert Ok(re) = regexp.from_string("(?<=mul\\()\\d+,\\d+(?=\\))")
  regexp.scan(with: re, content: input)
}

fn execute_instructions(matches: List(Match), result: Int) -> Int {
  case matches {
    [regexp.Match(content, _), ..rest] -> {
      let assert [a,b] = content |> string.split(",") |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
      execute_instructions(rest, result + a*b)
    }
    _ -> result
  }
}

pub fn pt_2(input: String) {
  let assert [first, ..rest] = input |> string.split("don't")
  let #(do, _) = find_do_and_dont(rest, [first], [])
  let matches = find_matches_for_list(do, [])
  execute_instructions(matches, 0)
}

fn find_matches_for_list(input: List(String), matches: List(Match)) -> List(Match) {
  case input {
    [first, ..rest] -> find_matches_for_list(rest, list.append(matches, find_matches_for_string(first)))
    _ -> matches
  }
}

fn find_do_and_dont(input: List(String), do: List(String), dont: List(String)) -> #(List(String), List(String)) {
  case input {
    [first, ..rest] -> {
      let assert [please_dont, ..please_do] = first |> string.split("do")
      find_do_and_dont(rest, list.append(do, please_do), list.append(dont, [please_dont]))
    }
    _ -> #(do, dont)
  }
}
