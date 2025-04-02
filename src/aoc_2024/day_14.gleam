import utils/tuple
import gleam/yielder
import utils/inter
import gleam/list
import gleam/string
import gleam/int
import utils/grid.{type Point, Point}

pub type Robot {
  Robot(pos: Point, vel: Point)
}

const grid_size = #(101, 103)
const running_time = 100

pub fn pt_1(input: List(Robot)) {
  input
  |> list.map(fn(robot) {
    calculate_position_after_seconds(robot, running_time)
  })
  |> count_quadrants(0, 0, 0, 0)
}

fn count_quadrants(robots: List(Point), q1: Int, q2: Int, q3: Int, q4: Int) -> Int {
  let grid_middle = Point(grid_size.0 / 2, grid_size.1 / 2)

  case robots {
    [first, ..rest] -> {
      case first.x != grid_middle.x && first.y != grid_middle.y {
        True -> {
          case first.x < grid_middle.x, first.y < grid_middle.y {
            True, True -> count_quadrants(rest, q1+1, q2, q3, q4)
            True, _ -> count_quadrants(rest, q1, q2+1, q3, q4)
            _, True -> count_quadrants(rest, q1, q2, q3+1, q4)
            _, _ -> count_quadrants(rest, q1, q2, q3, q4+1)
          }
        }
        False -> count_quadrants(rest, q1, q2, q3, q4)
      }
    }
    _ -> q1 * q2 * q3 * q4
  }
}

fn calculate_position_after_seconds(robot: Robot, seconds: Int) -> Point {
  let Robot(pos: Point(x, y), vel: Point(vx, vy)) = robot
  let pos_x = {x + vx * seconds} % grid_size.0
  let pos_y = {y + vy * seconds} % grid_size.1

  case pos_x < 0, pos_y < 0 {
    True, True -> Point(grid_size.0 + pos_x, grid_size.1 + pos_y)
    True, _ -> Point(grid_size.0 + pos_x, pos_y)
    _, True -> Point(pos_x, grid_size.1 + pos_y)
    _, _ -> Point(pos_x, pos_y)
  }
}

pub fn pt_2(input: List(Robot)) {
  let samples = 100
  let var_sample =
  yielder.range(1, samples)
  |> yielder.map(fn(seconds) {
    let robots = input
    |> list.map(fn(robot) {
      calculate_position_after_seconds(robot, seconds)
    })

    let var_x = robots |> list.map(fn(r) { r.x }) |> variance
    let var_y = robots |> list.map(fn(r) { r.y }) |> variance
    #(var_x, var_y)
  })
  |> yielder.to_list

  let avg_var_x =
  { var_sample |> list.map(tuple.first) |> int.sum } / samples
  let avg_var_y =
  { var_sample |> list.map(tuple.second) |> int.sum } / samples

  let assert Ok(#(seconds, _)) =
  yielder.range(1, 100_000_000)
  |> yielder.map(fn(seconds) {
    #(seconds, list.map(input, fn(r) {
      calculate_position_after_seconds(r, seconds)
    }))
  })
  |> yielder.find(fn(e) {
    let #(_, positions) = e
    let var_x = positions |> list.map(fn(p) { p.x }) |> variance
    let var_y = positions |> list.map(fn(p) { p.y }) |> variance
    var_x < avg_var_x / 2 && var_y < avg_var_y / 2
  })
  seconds
}

fn variance(values: List(Int)) -> Int {
  let avg = { values |> int.sum } / { values |> list.length }
  {
    values
    |> list.map(fn(value) {
      let diff = value - avg
      diff * diff
    })
    |> int.sum
  }
  / { values |> list.length }
}

pub fn parse(input: String) -> List(Robot) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [p, v] = string.split(line, " v=")
    let assert [x, y] = string.split(p, ",")
    let x = x |> string.trim |> string.drop_start(2)
    let assert [vx, vy] = string.split(v, ",")
    Robot(
      pos: Point(
        x: x |> inter.from_string,
        y: y |> inter.from_string,
      ),
      vel: Point(
        x: vx |> inter.from_string,
        y: vy |> inter.from_string,
      )
    )
  })
}
