import gleam/yielder
import gleam/result
import gleam/int
import gleam/list
import gleam/string
import utils/lister

pub type Block {
  File(id: Int, length: Int)
  Free(length: Int)
}

pub fn pt_1(input: List(Block)) {
  let disk = blocks_to_disk(input)
  compact_disk(disk, list.length(disk), [])
  |> calculate_checksum
}

fn calculate_checksum(disk: List(String)) -> Int {
  disk
  |> list.index_fold(0, fn(acc, el, ix) { acc + { int.parse(el) |> result.unwrap(0) } * ix})
}

fn compact_disk(disk: List(String), length: Int, compressed_disk: List(String)) -> List(String) {
  case disk {
    [] -> compressed_disk
    [first, ..rest] -> {
      case first {
        "." -> {
          let #(d, last, new_length) = get_last_element_no_dot(rest, list.length(rest))
          compact_disk(d, new_length - 1, list.append(compressed_disk, last))
        }
        _ -> compact_disk(rest, length - 1, list.append(compressed_disk, [first]))
      }
    }
  }
}

fn get_last_element_no_dot(l: List(String), length: Int) -> #(List(String), List(String), Int) {
  let #(d, last) = list.split(l, length - 1)
  case last {
    ["."] -> get_last_element_no_dot(d, length - 1)
    _ -> #(d, last, length)
  }
}

fn blocks_to_disk(blocks: List(Block)) -> List(String) {
  blocks
  |> list.flat_map(fn(block) {
    case block {
      File(id, length) -> list.repeat(int.to_string(id), length)
      Free(length) -> list.repeat(".", length)
    }
  })
}

pub fn pt_2(input: List(Block)) {
  let max_id = { input |> list.length } / 2
  input
  |> move_block_descending(max_id)
  |> list.map(fn(block) {
    case block {
      File(id, n) -> list.repeat(id, n)
      Free(n) -> list.repeat(0, n)
    }
  })
  |> list.flatten
  |> lister.enumerate
  |> list.map(fn(entry) {
    let #(index, id) = entry
    index * id
  })
  |> int.sum
}

fn remove_last_block(disk: List(Block)) -> #(List(Block), Block) {
  case disk {
    [] -> panic
    [last] -> #([], last)
    [head, ..rest] -> {
      let #(rest, last) = remove_last_block(rest)
      #([head, ..rest], last)
    }
  }
}

fn move_block_descending(disk: List(Block), max_id: Int) -> List(Block) {
  yielder.range(max_id, 0)
  |> yielder.fold(disk, fn(disk, id) {
    let #(updated_disk, fill) = remove_block_id(id, disk)
    case move_block(id, fill, updated_disk) {
      Ok(disk) -> disk
      Error(_) -> disk
    }
  })
}

fn move_block(id: Int, fill: Int, disk: List(Block)) -> Result(List(Block), Nil) {
  case disk {
    [] -> Error(Nil)
    [Free(empty), ..rest] if empty >= fill -> {
      Ok([File(id, fill), Free(empty - fill), ..rest])
    }
    [head, ..rest] ->
    move_block(id, fill, rest) |> result.map(fn(rest) { [head, ..rest] })
  }
}

fn remove_block_id(id: Int, disk: List(Block)) -> #(List(Block), Int) {
  case disk {
    [] -> panic
    [File(i, count), ..rest] if i == id -> #(
    [Free(count), ..rest] |> merge_empty,
    count,
    )
    [head, ..rest] -> {
      let #(rest, last) = remove_block_id(id, rest)
      #([head, ..rest], last)
    }
  }
}

fn merge_empty(disk: List(Block)) -> List(Block) {
  case disk {
    [] -> []
    [Free(e0), Free(e1), ..rest] -> [Free(e0 + e1), ..rest]
    disk -> disk
  }
}

pub fn parse(input: String) -> List(Block) {
  input
  |> string.to_graphemes
  |> list.index_map(fn(el, index) {
    case index % 2 {
      0 -> File(index/2, int.parse(el) |> result.unwrap(0))
      _ -> Free(int.parse(el) |> result.unwrap(0))
    }
  })
}
