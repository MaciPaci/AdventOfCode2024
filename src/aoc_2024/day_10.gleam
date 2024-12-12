import gleam/result
import gleam/int
import gleam/dict
import gleam/string
import gleam/list
import utils/grid.{type Point,type Grid,Point}
import utils/parser
import utils/directions.{type Direction, North, South, East, West}

pub fn pt_1(grid: Grid(Int)) {
  grid
  |> get_starting_points
  |> list.fold(0, fn(acc, point) {
    acc + {find_paths(point, grid, list.new()) |> list.unique |> list.length}
  })
}

pub fn find_paths(point: Point, grid: Grid(Int), found: List(Point)) -> List(Point) {
  let value = dict.get(grid, point) |> result.unwrap(-1)
  let directions = [North, South, East, West]

  directions
  |> list.fold(found, fn(acc, dir) {
    step(point, value, dir, grid, acc)
  })
}

fn step(point: Point, value: Int, dir: Direction, grid: Grid(Int), found: List(Point)) -> List(Point) {
  let next_point = directions.step(dir, point)
  let next_value = dict.get(grid, next_point) |> result.unwrap(-1)
  case next_value {
    _ if next_value != value + 1 -> found
    9 -> list.append(found, [next_point])
    _ -> find_paths(next_point, grid, found)
  }
}

pub fn get_starting_points(grid: Grid(Int)) -> List(Point) {
  grid
  |> dict.filter(fn(_, v) { v == 0 })
  |> dict.keys
}

pub fn pt_2(grid: Grid(Int)) {
  grid
  |> get_starting_points
  |> list.fold(0, fn(acc, point) {
    acc + find_unique_paths(point, grid)
  })
}

pub fn find_unique_paths(point: Point, grid: Grid(Int)) -> Int {
  let value = dict.get(grid, point) |> result.unwrap(-1)
  let directions = [North, South, East, West]

  directions
  |> list.fold(0, fn(acc, dir) {
    acc + step_unique(point, value, dir, grid)
  })
}

fn step_unique(point: Point, value: Int, dir: Direction, grid: Grid(Int)) -> Int {
  let next_point = directions.step(dir, point)
  let next_value = dict.get(grid, next_point) |> result.unwrap(-1)
  case next_value {
    _ if next_value != value + 1 -> 0
    9 -> 1
    _ -> find_unique_paths(next_point, grid)
  }
}

pub fn parse(input: String) -> Grid(Int) {
  input
  |> parser.parse_lines
  |> list.map(fn(line) {
    string.to_graphemes(line)
    |> list.map(fn(char) {
      int.parse(char) |> result.unwrap(-1)
    })})
  |> grid.to_grid(0, 0, dict.new())
}
