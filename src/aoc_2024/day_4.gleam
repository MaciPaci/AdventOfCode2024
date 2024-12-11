import gleam/bool
import gleam/result
import gleam/string
import gleam/list
import gleam/dict
import utils/parser
import utils/grid.{type Grid,type Point,Point}

const left = Point(0, -1)
const right = Point(0, 1)
const up = Point(1, 0)
const down = Point(-1, 0)
const up_left = Point(1, -1)
const up_right = Point(1, 1)
const down_left = Point(-1, -1)
const down_right = Point(-1, 1)

pub fn pt_1(input: String) {
  let input_lines = parser.parse_lines(input) |> list.map(fn(el) {string.to_graphemes(el)})
  let until = list.length(input_lines)
  let grid = grid.to_grid(input_lines, 0, 0, dict.new())
  traverse_grid(grid, 0, 0, until, 0)
}

fn traverse_grid(grid: Grid(String), row: Int, col: Int, until: Int, sum: Int) -> Int {
  case dict.get(grid, Point(row, col)) {
    Ok(char) if char == "X" -> {
      traverse_grid(grid, row, col + 1, until, sum + search_in_all_directions(grid, char, row, col))
    }
    Error(_) if row < until -> traverse_grid(grid, row + 1, 0, until, sum)
    Error(_) if row >= until -> sum
    _ -> traverse_grid(grid, row, col + 1, until, sum)
  }
}

fn search_in_all_directions(grid: Grid(String), current_char: String, row: Int, col: Int) -> Int {
  search_in_direction(grid, current_char, row, col, left) +
  search_in_direction(grid, current_char, row, col, right) +
  search_in_direction(grid, current_char, row, col, up) +
  search_in_direction(grid, current_char, row, col, down) +
  search_in_direction(grid, current_char, row, col, up_left) +
  search_in_direction(grid, current_char, row, col, up_right) +
  search_in_direction(grid, current_char, row, col, down_left) +
  search_in_direction(grid, current_char, row, col, down_right)
}

fn search_in_direction(grid: Grid(String), current_char: String, row: Int, col: Int, step: Point) -> Int {
  let next_char = grid |> dict.get(Point(row + step.x, col + step.y)) |> result.unwrap("")
  case current_char {
    "X" if next_char == "M" -> search_in_direction(grid, next_char, row+step.x, col+step.y, step)
    "M" if next_char == "A" -> search_in_direction(grid, next_char, row+step.x, col+step.y, step)
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

fn traverse_grid_pt2(grid: Grid(String), row: Int, col: Int, until: Int, sum: Int) -> Int {
  case dict.get(grid, Point(row, col)) {
    Ok(char) if char == "A" -> {
      traverse_grid_pt2(grid, row, col + 1, until, sum + search_on_diagonals(grid, row, col))
    }
    Error(_) if row < until -> traverse_grid_pt2(grid, row + 1, 0, until, sum)
    Error(_) if row >= until -> sum
    _ -> traverse_grid_pt2(grid, row, col + 1, until, sum)
  }
}

fn search_on_diagonals(grid: Grid(String), row: Int, col: Int) -> Int {
  bool.to_int(search_in_direction_pt2(grid, row, col, up_left, down_right) && search_in_direction_pt2(grid, row, col, up_right, down_left))
}

fn search_in_direction_pt2(grid: Grid(String), row: Int, col: Int, first_step: Point, second_step: Point) -> Bool {
  let first_char = grid |> dict.get(Point(row + first_step.x, col + first_step.y)) |> result.unwrap("")
  let next_char = case first_char {
    "M" -> "S"
    "S" -> "M"
    _ -> ""
  }

  let second_char = grid |> dict.get(Point(row + second_step.x, col + second_step.y)) |> result.unwrap("")
  case next_char == second_char && next_char != "" {
    True -> True
    False -> False
  }
}
