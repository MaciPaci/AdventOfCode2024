pub type Direction {
  North
  East
  South
  West
  NorthWest
  NorthEast
  SouthWest
  SouthEast
}

pub fn rotate_90_degrees_right(dir: Direction) -> Direction {
  case dir {
    North -> East
    East -> South
    South -> West
    West -> North
    NorthWest -> NorthEast
    NorthEast -> SouthEast
    SouthEast -> SouthWest
    SouthWest -> NorthWest
  }
}

pub fn step(dir: Direction, pos: #(Int, Int)) -> #(Int, Int) {
  let #(x, y) = pos
  case dir {
    North -> #(x - 1, y)
    East -> #(x, y + 1)
    South -> #(x + 1, y)
    West -> #(x, y - 1)
    NorthWest -> #(x - 1, y - 1)
    NorthEast -> #(x - 1, y + 1)
    SouthEast -> #(x + 1, y + 1)
    SouthWest -> #(x + 1, y - 1)
  }
}
