import gleam/string
import utils/parser
import gleam/list
import gleam/dict.{type Dict}

pub type Point {
  Point(x: Int, y: Int)
}

pub type Grid(a) = Dict(Point, a)

pub fn to_grid(input: List(List(a)), row: Int, col: Int, grid: Grid(a)) -> Grid(a) {
  case input {
    [first, ..rest] -> to_grid(rest, row+1, 0, add_row_to_grid(first, row, col, grid))
    _ -> grid
  }
}

fn add_row_to_grid(input: List(a), row: Int, col: Int, grid: Grid(a)) {
  case input {
    [first, ..rest] -> add_row_to_grid(rest, row, col + 1, grid |> dict.insert(Point(row, col), first))
    _ -> grid
  }
}

pub fn get_max_grid_pos(grid: Grid(a)) -> Point {
  let acc = Point(0, 0)
  dict.keys(grid)
  |> list.fold(acc, fn(acc, el) {
    let Point(row, col) = el
    case row > acc.x, col > acc.y {
      True, _ -> Point(row, acc.y)
      _, True -> Point(acc.x, col)
      _, _ -> acc
    }
  })
}

pub fn get_max_pos(input: String) -> Point {
  input
  |> parser.parse_lines()
  |> list.map(fn(line) {
    string.to_graphemes(line)
  })
  |> to_grid(0, 0, dict.new())
  |> get_max_grid_pos()
}
