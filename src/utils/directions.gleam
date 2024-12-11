import utils/grid.{type Point,Point}

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

pub fn step(dir: Direction, pos: Point) -> Point {
  let Point(x, y) = pos
  case dir {
    North -> Point(x - 1, y)
    East -> Point(x, y + 1)
    South -> Point(x + 1, y)
    West -> Point(x, y - 1)
    NorthWest -> Point(x - 1, y - 1)
    NorthEast -> Point(x - 1, y + 1)
    SouthEast -> Point(x + 1, y + 1)
    SouthWest -> Point(x + 1, y - 1)
  }
}
