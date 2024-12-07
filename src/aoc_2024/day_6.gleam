import gleam/set.{type Set}
import gleam/result
import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import utils/grid
import utils/parser
import utils/directions.{type Direction}

pub fn pt_1(input: String) {
  let input_lines = parser.parse_lines(input) |> list.map(fn(el) {string.to_graphemes(el)})
  let grid = grid.to_grid(input_lines, 0, 0, dict.new())
  let starting_position = grid |> dict.filter(fn(_, v) {v == "^"}) |> dict.keys() |> list.first() |> result.unwrap(#(0, 0))

  move_guard(grid, starting_position, directions.North, [])
  |> list.unique()
  |> list.length()
}

fn move_guard(
  grid: Dict(#(Int, Int), String),
  position: #(Int, Int),
  direction: Direction,
  visited: List(#(Int, Int))
  ) -> List(#(Int, Int))
{
  let new_visited = list.append(visited, [position])
  let next_position = grid |> dict.get(directions.step(direction, position)) |> result.unwrap("")

  case next_position {
    "#" -> {
      let new_direction = directions.rotate_90_degrees_right(direction)
      move_guard(grid, directions.step(new_direction, position), new_direction, new_visited)
    }
    "." | "^" -> move_guard(grid, directions.step(direction, position), direction, new_visited)
    _ -> new_visited
  }
}

pub fn pt_2(input: String) {
  let input_lines = parser.parse_lines(input) |> list.map(fn(el) {string.to_graphemes(el)})
  let grid = grid.to_grid(input_lines, 0, 0, dict.new())
  let starting_position = grid |> dict.filter(fn(_, v) {v == "^"}) |> dict.keys() |> list.first() |> result.unwrap(#(0, 0))

  let guard_path = move_guard(grid, starting_position, directions.North, []) |> list.unique()
  check_obstacles(grid, guard_path, starting_position, 0)
}

fn check_obstacles(grid: Dict(#(Int, Int), String), potential_obstacles: List(#(Int, Int)), position: #(Int, Int), sum: Int) -> Int {
  case potential_obstacles {
    [] -> sum
    [first, ..rest] -> {
      let cycle_found = grid
      |> dict.insert(first, "#")
      |> is_guard_moving_in_loop(set.new(), position, directions.North)

      case cycle_found {
        True -> check_obstacles(grid, rest, position, sum+1)
        False -> check_obstacles(grid, rest, position, sum)
      }
    }
  }
}

fn is_guard_moving_in_loop(
  grid: Dict(#(Int, Int), String),
  visited: Set(#(Direction, #(Int, Int))),
  position: #(Int, Int),
  direction: Direction,
  ) -> Bool
{
  let new_visited = set.insert(visited, #(direction, position))
  let next_position = directions.step(direction, position)
  let cell = grid |> dict.get(next_position) |> result.unwrap("")

  case set.contains(new_visited, #(direction, next_position)) {
    True -> True
    False -> {
      case cell {
        "#" -> is_guard_moving_in_loop(grid, new_visited, position, directions.rotate_90_degrees_right(direction))
        "." | "^" -> is_guard_moving_in_loop(grid, new_visited, next_position, direction)
        _ -> False
      }
    }
  }
}
