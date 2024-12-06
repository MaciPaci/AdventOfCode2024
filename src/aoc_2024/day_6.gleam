import gleam/result
import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import gleam/otp/task
import utils/grid
import utils/parser
import utils/directions

pub fn pt_1(input: String) {
  let input_lines = parser.parse_lines(input) |> list.map(fn(el) {string.to_graphemes(el)})
  let grid = grid.to_grid(input_lines, 0, 0, dict.new())
  let starting_position = grid |> dict.filter(fn(_, v) {v == "^"}) |> dict.keys() |> list.first() |> result.unwrap(#(0, 0))

  move_guard(grid, starting_position, #(-1, 0), [])
  |> list.unique()
  |> list.length()
}

fn move_guard(
  grid: Dict(#(Int, Int), String),
  position: #(Int, Int),
  direction: #(Int, Int),
  visited: List(#(Int, Int))
  ) -> List(#(Int, Int))
{
  let new_visited = list.append(visited, [position])
  let next_position = grid |> dict.get(#(position.0 + direction.0, position.1 + direction.1)) |> result.unwrap("")

  case next_position {
    "#" -> {
      let new_direction = directions.turn_right(direction)
      move_guard(grid, #(position.0 + new_direction.0, position.1 + new_direction.1), new_direction, new_visited)
    }
    "." | "^" -> move_guard(grid, #(position.0 + direction.0, position.1 + direction.1), direction, new_visited)
    _ -> new_visited
  }
}

pub fn pt_2(input: String) {
  let input_lines = parser.parse_lines(input) |> list.map(fn(el) {string.to_graphemes(el)})
  let grid = grid.to_grid(input_lines, 0, 0, dict.new())
  let starting_position = grid |> dict.filter(fn(_, v) {v == "^"}) |> dict.keys() |> list.first() |> result.unwrap(#(0, 0))

  let guard_path = move_guard(grid, starting_position, #(-1, 0), [])
  let assert [list1, list2, list3, list4, list5, list6, list7, list8] = list.unique(guard_path) |> list.sized_chunk(list.length(guard_path) / 8)

  let t1 = task.async(fn() {check_obstacles(grid, list1, starting_position, 0)})
  let t2 = task.async(fn() {check_obstacles(grid, list2, starting_position, 0)})
  let t3 = task.async(fn() {check_obstacles(grid, list3, starting_position, 0)})
  let t4 = task.async(fn() {check_obstacles(grid, list4, starting_position, 0)})
  let t5 = task.async(fn() {check_obstacles(grid, list5, starting_position, 0)})
  let t6 = task.async(fn() {check_obstacles(grid, list6, starting_position, 0)})
  let t7 = task.async(fn() {check_obstacles(grid, list7, starting_position, 0)})
  let t8 = task.async(fn() {check_obstacles(grid, list8, starting_position, 0)})

  let assert [Ok(sum1), Ok(sum2), Ok(sum3), Ok(sum4), Ok(sum5), Ok(sum6), Ok(sum7), Ok(sum8)] = task.try_await_all([t1, t2, t3, t4, t5, t6, t7, t8], 999999)
  sum1 + sum2 + sum3 + sum4 + sum5 + sum6 + sum7 + sum8
}

fn check_obstacles(grid: Dict(#(Int, Int), String), potential_obstacles: List(#(Int, Int)), position: #(Int, Int), sum: Int) -> Int {
  case potential_obstacles {
    [first, ..rest] -> {
      let cycle_found = grid
      |> dict.insert(first, "#")
      |> is_guard_moving_in_cycle([], position, #(-1, 0), position)

      case cycle_found {
        True -> {
          check_obstacles(grid, rest, position, sum+1)
        }
        False -> check_obstacles(grid, rest, position, sum)
      }
    }
    _ -> sum
  }
}

fn is_guard_moving_in_cycle(
  grid: Dict(#(Int, Int), String),
  visited: List(#(Int, Int)),
  position: #(Int, Int),
  direction: #(Int, Int),
  starting_position: #(Int, Int),
  ) -> Bool
{
  let new_visited = list.append(visited, [position])
  let next_position = grid |> dict.get(#(position.0 + direction.0, position.1 + direction.1)) |> result.unwrap("")

  let indexes = case list.count(visited, fn(x) { x == position }) >= 3 {
    True -> {
      list.index_fold(visited, [], fn(acc, item, index) {
        case item == position {
          True -> list.append(acc, [index])
          False -> acc
        }
      })
    }
    False -> []
  }

  let potential_cycle = list.map(make_pairs(indexes, []), fn(el) {el.1 - el.0})
  case check_for_cycle(potential_cycle) {
    False -> {
      case next_position {
        "#" -> {
          let new_direction = directions.turn_right(direction)
          is_guard_moving_in_cycle(grid, new_visited, #(position.0, position.1), new_direction, starting_position)
        }
        "." | "^" -> is_guard_moving_in_cycle(grid, new_visited, #(position.0 + direction.0, position.1 + direction.1), direction, starting_position)
        _ -> False
      }
    }
    True -> True
  }
}

fn make_pairs(list: List(Int), pairs: List(#(Int, Int))) -> List(#(Int, Int)) {
  case list {
    [first, second, ..rest] -> {
      make_pairs([second, ..rest], list.append(pairs, [#(first, second)]))
    }
    _ -> pairs
  }
}

fn check_for_cycle(potential_cycle: List(Int)) -> Bool {
  let l = list.combination_pairs(potential_cycle)
  l |> list.any(fn(el) {el.0 % el.1 == 0 && el.0 != 0 && el.1 != 0})
}
