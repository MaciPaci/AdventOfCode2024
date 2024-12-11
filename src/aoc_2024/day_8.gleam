import gleam/int
import utils/tuple
import gleam/result
import gleam/string
import gleam/list
import gleam/dict.{type Dict}
import utils/parser
import utils/grid.{type Point, Point}

pub fn pt_1(input: #(Dict(String, List(Point)), Point)) {
  input
  |> tuple.first
  |> dict.values
  |> find_all_antinodes(input.1)
  |> list.unique
  |> list.length
}

fn find_all_antinodes(antennas: List(List(Point)), max: Point) -> List(Point) {
  use antinodes, antennas_row <- list.fold(antennas, list.new())
  let antennas_pairs = list.combination_pairs(antennas_row)
  use antinodes, antennas_pairs <- list.fold(antennas_pairs, antinodes)
  find_antinodes_for_pair(antinodes, antennas_pairs, max)
}

fn find_antinodes_for_pair(antinodes: List(Point), antenna_pair: #(Point, Point), max: Point) -> List(Point) {
  let #(Point(row1, col1), Point(row2, col2)) = antenna_pair
  let row_diff = row1 - row2
  let col_diff = col1 - col2

  let potential_antinodes = [
  Point(row1 - row_diff, col1 - col_diff),
  Point(row2 + row_diff, col2 + col_diff),
  Point(row1 + row_diff, col1 + col_diff),
  Point(row2 - row_diff, col2 - col_diff)
  ]

  let filtered_antinodes = list.filter(potential_antinodes, fn(antinode) {
    case antinode == Point(row1, col1) || antinode == Point(row2, col2) || antinode.x < 0 || antinode.y < 0 || antinode.x > max.x || antinode.y > max.y {
      True -> False
      _ -> True
    }
  })
  list.append(antinodes, filtered_antinodes)
}

pub fn pt_2(input: #(Dict(String, List(Point)), Point)) {
  input
  |> tuple.first
  |> dict.values
  |> find_all_antinodes_harmonics(input.1)
  |> list.unique
  |> list.length
}

fn find_all_antinodes_harmonics(antennas: List(List(Point)), max: Point) -> List(Point) {
  use antinodes, antennas_row <- list.fold(antennas, list.new())
  let antennas_pairs = list.combination_pairs(antennas_row)
  use antinodes, antennas_pairs <- list.fold(antennas_pairs, antinodes)
  find_harmonics_for_pair(antinodes, antennas_pairs, max)
}

fn find_harmonics_for_pair(antinodes: List(Point), antenna_pair: #(Point, Point), max: Point) -> List(Point) {
  let potential_antinodes = find_potential_antinode_harmonics(antenna_pair, max, list.new())

  let filtered_antinodes = list.filter(potential_antinodes, fn(antinode) {
    case antinode.x < 0 || antinode.y < 0 || antinode.x > max.x || antinode.y > max.y {
      True -> False
      _ -> True
    }
  })
  list.append(antinodes, filtered_antinodes)
}

fn find_potential_antinode_harmonics(antenna_pair: #(Point, Point), max: Point, potential_harmonics: List(Point)) -> List(Point) {
  let #(Point(row1, col1), Point(row2, col2)) = antenna_pair
  let row_diff = row1 - row2
  let col_diff = col1 - col2
  let times_row = int.absolute_value(max.x / row_diff)
  let times_col = int.absolute_value(max.y / col_diff)
  let max_iter = int.max(times_row, times_col)

  calculate_single_harmonic(antenna_pair, row_diff, col_diff, max_iter, potential_harmonics)
}

fn calculate_single_harmonic(antenna_pair: #(Point, Point), diff_row: Int, diff_col: Int, max_iter: Int, potential_harmonics: List(Point)) -> List(Point) {
  let #(Point(row1, col1), Point(row2, col2)) = antenna_pair
  let mul_row = max_iter * diff_row
  let mul_col = max_iter * diff_col

  let harmonics = [
  Point(row1 - mul_row, col1 - mul_col),
  Point(row1 + mul_row, col1 + mul_col),
  Point(row2 + mul_row, col2 + mul_col),
  Point(row2 - mul_row, col2 - mul_col)
  ]

  case max_iter <= 0 {
    True -> potential_harmonics
    False -> calculate_single_harmonic(antenna_pair, diff_row, diff_col, max_iter - 1, list.append(potential_harmonics, harmonics))
  }
}

pub fn parse(input: String) -> #(Dict(String, List(Point)), Point) {
  #(
  input
  |> parser.parse_lines()
  |> list.map(fn(line) {
    string.to_graphemes(line)
  })
  |> grid.to_grid(0, 0, dict.new())
  |> dict.to_list()
  |> list.filter(fn(el) {
    case el {
      #(Point(_, _), ".") -> False
      _ -> True
    }
  })
  |> list.map(fn(el) {
    let #(pos, symbol) = el
    #(symbol, pos)
  })
  |> list.fold(dict.new(), fn(d, el) {
    let #(symbol, pos) = el
    case symbol != "." {
      True -> dict.insert(d, symbol, list.append(dict.get(d, symbol) |> result.unwrap([]), [pos]))
      False -> d
    }
  }),
  grid.get_max_pos(input)
  )
}
