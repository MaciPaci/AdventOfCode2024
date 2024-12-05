import gleam/bool
import gleam/result
import gleam/string
import gleam/list
import gleam/dict.{type Dict}
import utils/parser
import utils/grid

const left = #(0, -1)
const right = #(0, 1)
const up = #(1, 0)
const down = #(-1, 0)
const up_left = #(1, -1)
const up_right = #(1, 1)
const down_left = #(-1, -1)
const down_right = #(-1, 1)

pub fn pt_1(input: String) {
  let input_lines = parser.parse_lines(input) |> list.map(fn(el) {string.to_graphemes(el)})
  let until = list.length(input_lines)
  let grid = grid.to_grid(input_lines, 0, 0, dict.new())
  traverse_grid(grid, 0, 0, until, 0)
}

fn traverse_grid(grid: Dict(#(Int, Int), String), row: Int, col: Int, until: Int, sum: Int) -> Int {
  case dict.get(grid, #(row, col)) {
    Ok(char) if char == "X" -> {
      traverse_grid(grid, row, col + 1, until, sum + search_in_all_directions(grid, char, row, col))
    }
    Error(_) if row < until -> traverse_grid(grid, row + 1, 0, until, sum)
    Error(_) if row >= until -> sum
    _ -> traverse_grid(grid, row, col + 1, until, sum)
  }
}

fn search_in_all_directions(grid: Dict(#(Int, Int), String), current_char: String, row: Int, col: Int) -> Int {
  search_in_direction(grid, current_char, row, col, left) +
  search_in_direction(grid, current_char, row, col, right) +
  search_in_direction(grid, current_char, row, col, up) +
  search_in_direction(grid, current_char, row, col, down) +
  search_in_direction(grid, current_char, row, col, up_left) +
  search_in_direction(grid, current_char, row, col, up_right) +
  search_in_direction(grid, current_char, row, col, down_left) +
  search_in_direction(grid, current_char, row, col, down_right)
}

fn search_in_direction(grid: Dict(#(Int, Int), String), current_char: String, row: Int, col: Int, step: #(Int, Int)) -> Int {
  let next_char = grid |> dict.get(#(row + step.0, col + step.1)) |> result.unwrap("")
  case current_char {
    "X" if next_char == "M" -> search_in_direction(grid, next_char, row+step.0, col+step.1, step)
    "M" if next_char == "A" -> search_in_direction(grid, next_char, row+step.0, col+step.1, step)
    "A" if next_char == "S" -> 1
    _ -> 0
  }
}

pub fn pt_2(input: String) {
  let input_lines = parser.parse_lines(input) |> list.map(fn(el) {string.to_graphemes(el)})
  let until = list.length(input_lines)
  let grid = grid.to_grid(input_lines, 0, 0, dict.new())
  traverse_grid_pt2(grid, 0, 0, until, 0)
}

fn traverse_grid_pt2(grid: Dict(#(Int, Int), String), row: Int, col: Int, until: Int, sum: Int) -> Int {
  case dict.get(grid, #(row, col)) {
    Ok(char) if char == "A" -> {
      traverse_grid_pt2(grid, row, col + 1, until, sum + search_on_diagonals(grid, row, col))
    }
    Error(_) if row < until -> traverse_grid_pt2(grid, row + 1, 0, until, sum)
    Error(_) if row >= until -> sum
    _ -> traverse_grid_pt2(grid, row, col + 1, until, sum)
  }
}

fn search_on_diagonals(grid: Dict(#(Int, Int), String), row: Int, col: Int) -> Int {
  bool.to_int(search_in_direction_pt2(grid, row, col, up_left, down_right) && search_in_direction_pt2(grid, row, col, up_right, down_left))
}

fn search_in_direction_pt2(grid: Dict(#(Int, Int), String), row: Int, col: Int, first_step: #(Int, Int), second_step: #(Int, Int)) -> Bool {
  let first_char = grid |> dict.get(#(row + first_step.0, col + first_step.1)) |> result.unwrap("")
  let next_char = case first_char {
    "M" -> "S"
    "S" -> "M"
    _ -> ""
  }

  let second_char = grid |> dict.get(#(row + second_step.0, col + second_step.1)) |> result.unwrap("")
  case next_char == second_char && next_char != "" {
    True -> True
    False -> False
  }
}
