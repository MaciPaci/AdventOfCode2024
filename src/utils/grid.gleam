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
