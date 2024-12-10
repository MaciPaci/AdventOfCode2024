import gleam/int
import utils/tuple
import gleam/result
import gleam/string
import gleam/list
import gleam/dict.{type Dict}
import utils/parser
import utils/grid

pub fn pt_1(input: #(Dict(String, List(#(Int, Int))), #(Int, Int))) {
  input
  |> tuple.first
  |> dict.values
  |> find_all_antinodes(input.1)
  |> list.unique
  |> list.length
}

fn find_all_antinodes(antennas: List(List(#(Int, Int))), max: #(Int, Int)) -> List(#(Int, Int)) {
  use antinodes, antennas_row <- list.fold(antennas, list.new())
  let antennas_pairs = list.combination_pairs(antennas_row)
  use antinodes, antennas_pairs <- list.fold(antennas_pairs, antinodes)
  find_antinodes_for_pair(antinodes, antennas_pairs, max)
}

fn find_antinodes_for_pair(antinodes: List(#(Int, Int)), antenna_pair: #(#(Int, Int), #(Int, Int)), max: #(Int, Int)) -> List(#(Int, Int)) {
  let #(#(row1, col1), #(row2, col2)) = antenna_pair
  let row_diff = row1 - row2
  let col_diff = col1 - col2

  let potential_antinodes = [
  #(row1 - row_diff, col1 - col_diff),
  #(row2 + row_diff, col2 + col_diff),
  #(row1 + row_diff, col1 + col_diff),
  #(row2 - row_diff, col2 - col_diff)
  ]

  let filtered_antinodes = list.filter(potential_antinodes, fn(antinode) {
    case antinode == #(row1, col1) || antinode == #(row2, col2) || antinode.0 < 0 || antinode.1 < 0 || antinode.0 > max.0 || antinode.1 > max.1 {
      True -> False
      _ -> True
    }
  })
  list.append(antinodes, filtered_antinodes)
}

pub fn pt_2(input: #(Dict(String, List(#(Int, Int))), #(Int, Int))) {
  input
  |> tuple.first
  |> dict.values
  |> find_all_antinodes_harmonics(input.1)
  |> list.unique
  |> list.length
}

fn find_all_antinodes_harmonics(antennas: List(List(#(Int, Int))), max: #(Int, Int)) -> List(#(Int, Int)) {
  use antinodes, antennas_row <- list.fold(antennas, list.new())
  let antennas_pairs = list.combination_pairs(antennas_row)
  use antinodes, antennas_pairs <- list.fold(antennas_pairs, antinodes)
  find_harmonics_for_pair(antinodes, antennas_pairs, max)
}

fn find_harmonics_for_pair(antinodes: List(#(Int, Int)), antenna_pair: #(#(Int, Int), #(Int, Int)), max: #(Int, Int)) -> List(#(Int, Int)) {
  let potential_antinodes = find_potential_antinode_harmonics(antenna_pair, max, list.new())

  let filtered_antinodes = list.filter(potential_antinodes, fn(antinode) {
    case antinode.0 < 0 || antinode.1 < 0 || antinode.0 > max.0 || antinode.1 > max.1 {
      True -> False
      _ -> True
    }
  })
  list.append(antinodes, filtered_antinodes)
}

fn find_potential_antinode_harmonics(antenna_pair: #(#(Int, Int), #(Int, Int)), max: #(Int, Int), potential_harmonics: List(#(Int, Int))) -> List(#(Int, Int)) {
  let #(#(row1, col1), #(row2, col2)) = antenna_pair
  let row_diff = row1 - row2
  let col_diff = col1 - col2
  let times_row = int.absolute_value(max.0 / row_diff)
  let times_col = int.absolute_value(max.1 / col_diff)
  let max_iter = int.max(times_row, times_col)

  calculate_single_harmonic(antenna_pair, row_diff, col_diff, max_iter, potential_harmonics)
}

fn calculate_single_harmonic(antenna_pair: #(#(Int, Int), #(Int, Int)), diff_row: Int, diff_col: Int, max_iter: Int, potential_harmonics: List(#(Int, Int))) -> List(#(Int, Int)) {
  let #(#(row1, col1), #(row2, col2)) = antenna_pair
  let mul_row = max_iter * diff_row
  let mul_col = max_iter * diff_col

  let harmonics = [
  #(row1 - mul_row, col1 - mul_col),
  #(row1 + mul_row, col1 + mul_col),
  #(row2 + mul_row, col2 + mul_col),
  #(row2 - mul_row, col2 - mul_col)
  ]

  case max_iter <= 0 {
    True -> potential_harmonics
    False -> calculate_single_harmonic(antenna_pair, diff_row, diff_col, max_iter - 1, list.append(potential_harmonics, harmonics))
  }
}

pub fn parse(input: String) -> #(Dict(String, List(#(Int, Int))), #(Int, Int)) {
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
      #(#(_, _), ".") -> False
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
