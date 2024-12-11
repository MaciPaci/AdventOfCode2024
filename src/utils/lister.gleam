import gleam/list

pub fn sum(ints: List(Int)) -> Int {
  ints
  |> list.fold(0, fn(acc, x) { acc + x })
}

pub fn enumerate(l: List(a)) -> List(#(Int, a)) {
  l
  |> list.index_map(fn(x, i) { #(i, x) })
}
