import gleam/string
import utils/parser
import gleam/list
import gleam/dict.{type Dict}

pub fn to_grid(input: List(List(String)), row: Int, col: Int, grid: Dict(#(Int, Int), String)) -> Dict(#(Int, Int), String) {
  case input {
    [first, ..rest] -> to_grid(rest, row+1, 0, add_row_to_grid(first, row, col, grid))
    _ -> grid
  }
}

fn add_row_to_grid(input: List(String), row: Int, col: Int, grid: Dict(#(Int, Int), String)) {
  case input {
    [first, ..rest] -> add_row_to_grid(rest, row, col + 1, grid |> dict.insert(#(row, col), first))
    _ -> grid
  }
}

pub fn get_max_grid_pos(grid: Dict(#(Int, Int), String)) -> #(Int, Int) {
  let acc = #(0, 0)
  dict.keys(grid)
  |> list.fold(acc, fn(acc, el) {
    let #(row, col) = el
    case row > acc.0, col > acc.1 {
      True, _ -> #(row, acc.1)
      _, True -> #(acc.0, col)
      _, _ -> acc
    }
  })
}

pub fn get_max_pos(input: String) -> #(Int, Int) {
  input
  |> parser.parse_lines()
  |> list.map(fn(line) {
    string.to_graphemes(line)
  })
  |> to_grid(0, 0, dict.new())
  |> get_max_grid_pos()
}
