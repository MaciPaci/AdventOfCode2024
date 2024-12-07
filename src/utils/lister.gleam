import gleam/list

pub fn sum(ints: List(Int)) -> Int {
  ints
  |> list.fold(0, fn(acc, x) { acc + x })
}

pub fn enumerate(ints: List(Int)) -> List(#(Int, Int)) {
  ints
  |> list.index_map(fn(x, i) { #(i, x) })
}
