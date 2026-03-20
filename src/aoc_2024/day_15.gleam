import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import utils/directions.{type Direction, East, North, South, West}
import utils/grid.{type Grid, type Point, Point}
import utils/parser

pub type Warehouse {
  Warehouse(
    grid: Grid(String),
    robot_pos: Point,
    boxes_pos: List(Point),
    walls: List(Point),
    moves: List(Direction),
  )
}

type WideWarehouse {
  WideWarehouse(
    robot_pos: Point,
    boxes_pos: List(Point),
    walls: Dict(Point, Nil),
    moves: List(Direction),
  )
}

pub fn pt_1(input: Warehouse) {
  let final_warehouse = move(input)
  gps_sum(final_warehouse.boxes_pos)
}

pub fn pt_2(input: Warehouse) {
  input
  |> widen_warehouse
  |> move_wide
  |> wide_gps_sum
}

fn gps_sum(boxes: List(Point)) -> Int {
  boxes
  |> list.fold(0, fn(acc, box_pos) { acc + 100 * box_pos.x + box_pos.y })
}

fn move(warehouse: Warehouse) -> Warehouse {
  case warehouse.moves {
    [] -> warehouse
    [dir, ..rest] -> {
      move(move_object(
        dir,
        Warehouse(
          grid: warehouse.grid,
          robot_pos: warehouse.robot_pos,
          boxes_pos: warehouse.boxes_pos,
          walls: warehouse.walls,
          moves: rest,
        ),
      ))
    }
  }
}

fn move_object(dir: Direction, warehouse: Warehouse) -> Warehouse {
  let next_pos = directions.step(dir, warehouse.robot_pos)
  case list.contains(warehouse.walls, next_pos) {
    True -> warehouse
    False -> {
      case
        check_push_chain(
          warehouse.robot_pos,
          dir,
          warehouse.walls,
          warehouse.boxes_pos,
          [],
        )
      {
        Error(_) -> warehouse
        Ok(box_chain) -> {
          case box_chain {
            [] -> Warehouse(..warehouse, robot_pos: next_pos)
            _ -> {
              let filtered_boxes =
                warehouse.boxes_pos
                |> list.filter(fn(box_pos) {
                  !list.contains(box_chain, box_pos)
                })

              let new_boxes =
                box_chain
                |> list.map(fn(box_pos) { directions.step(dir, box_pos) })
                |> list.append(filtered_boxes)

              Warehouse(..warehouse, robot_pos: next_pos, boxes_pos: new_boxes)
            }
          }
        }
      }
    }
  }
}

fn check_push_chain(
  robot_pos: Point,
  dir: Direction,
  walls: List(Point),
  boxes: List(Point),
  box_chain: List(Point),
) -> Result(List(Point), Nil) {
  let next_pos = directions.step(dir, robot_pos)
  case list.contains(walls, next_pos) {
    True -> Error(Nil)
    False -> {
      case list.contains(boxes, next_pos) {
        True -> {
          check_push_chain(next_pos, dir, walls, boxes, [next_pos, ..box_chain])
        }
        False -> Ok(box_chain)
      }
    }
  }
}

fn widen_warehouse(warehouse: Warehouse) -> WideWarehouse {
  let scaled_walls =
    warehouse.walls
    |> list.map(fn(wall) {
      let left_wall = scale_point(wall)
      let Point(x, y) = left_wall
      [#(left_wall, Nil), #(Point(x, y + 1), Nil)]
    })
    |> list.flatten
    |> dict.from_list

  WideWarehouse(
    robot_pos: scale_point(warehouse.robot_pos),
    boxes_pos: warehouse.boxes_pos |> list.map(scale_point),
    walls: scaled_walls,
    moves: warehouse.moves,
  )
}

fn scale_point(point: Point) -> Point {
  let Point(x, y) = point
  Point(x, y * 2)
}

fn move_wide(warehouse: WideWarehouse) -> WideWarehouse {
  case warehouse.moves {
    [] -> warehouse
    [dir, ..rest] -> {
      move_wide(attempt_wide_move(
        dir,
        WideWarehouse(
          robot_pos: warehouse.robot_pos,
          boxes_pos: warehouse.boxes_pos,
          walls: warehouse.walls,
          moves: rest,
        ),
      ))
    }
  }
}

fn attempt_wide_move(dir: Direction, warehouse: WideWarehouse) -> WideWarehouse {
  let next_pos = directions.step(dir, warehouse.robot_pos)

  case dict.has_key(warehouse.walls, next_pos) {
    True -> warehouse
    False -> {
      let box_lookup = build_box_lookup(warehouse.boxes_pos)

      case dict.get(box_lookup, next_pos) {
        Error(_) -> WideWarehouse(..warehouse, robot_pos: next_pos)
        Ok(first_box) -> {
          case
            collect_boxes_to_move(
              first_box,
              dir,
              warehouse.walls,
              box_lookup,
              [],
            )
          {
            Error(_) -> warehouse
            Ok(boxes_to_move) -> {
              let moved_boxes =
                boxes_to_move
                |> list.map(fn(box_pos) { #(box_pos, Nil) })
                |> dict.from_list

              let remaining_boxes =
                warehouse.boxes_pos
                |> list.filter(fn(box_pos) {
                  !dict.has_key(moved_boxes, box_pos)
                })

              let shifted_boxes =
                boxes_to_move
                |> list.map(fn(box_pos) { directions.step(dir, box_pos) })

              WideWarehouse(
                ..warehouse,
                robot_pos: next_pos,
                boxes_pos: shifted_boxes |> list.append(remaining_boxes),
              )
            }
          }
        }
      }
    }
  }
}

fn build_box_lookup(boxes: List(Point)) -> Dict(Point, Point) {
  boxes
  |> list.fold(dict.new(), fn(acc, box_pos) {
    let Point(x, y) = box_pos

    acc
    |> dict.insert(box_pos, box_pos)
    |> dict.insert(Point(x, y + 1), box_pos)
  })
}

fn collect_boxes_to_move(
  box_pos: Point,
  dir: Direction,
  walls: Dict(Point, Nil),
  box_lookup: Dict(Point, Point),
  seen: List(Point),
) -> Result(List(Point), Nil) {
  case list.contains(seen, box_pos) {
    True -> Ok(seen)
    False -> {
      let updated_seen = [box_pos, ..seen]

      collect_boxes_from_targets(
        box_front_cells(box_pos, dir),
        dir,
        walls,
        box_lookup,
        updated_seen,
      )
    }
  }
}

fn collect_boxes_from_targets(
  targets: List(Point),
  dir: Direction,
  walls: Dict(Point, Nil),
  box_lookup: Dict(Point, Point),
  seen: List(Point),
) -> Result(List(Point), Nil) {
  case targets {
    [] -> Ok(seen)
    [target, ..rest] -> {
      case dict.has_key(walls, target) {
        True -> Error(Nil)
        False -> {
          case dict.get(box_lookup, target) {
            Error(_) -> collect_boxes_from_targets(rest, dir, walls, box_lookup, seen)
            Ok(next_box) -> {
              case collect_boxes_to_move(next_box, dir, walls, box_lookup, seen) {
                Error(_) -> Error(Nil)
                Ok(updated_seen) -> {
                  collect_boxes_from_targets(
                    rest,
                    dir,
                    walls,
                    box_lookup,
                    updated_seen,
                  )
                }
              }
            }
          }
        }
      }
    }
  }
}

fn box_front_cells(box_pos: Point, dir: Direction) -> List(Point) {
  let Point(x, y) = box_pos

  case dir {
    North -> [Point(x - 1, y), Point(x - 1, y + 1)]
    East -> [Point(x, y + 2)]
    South -> [Point(x + 1, y), Point(x + 1, y + 1)]
    West -> [Point(x, y - 1)]
    _ -> panic
  }
}

fn wide_gps_sum(warehouse: WideWarehouse) -> Int {
  gps_sum(warehouse.boxes_pos)
}

pub fn parse(input: String) -> Warehouse {
  let assert Ok(#(warehouse, moves)) = string.split_once(input, "\n\n")
  let warehouse_grid =
    parser.parse_lines(warehouse)
    |> list.map(fn(line) { string.to_graphemes(line) })
    |> grid.to_grid(0, 0, dict.new())
  let assert [robot_pos] = grid.find_in_grid(warehouse_grid, "@")
  let boxes_pos = grid.find_in_grid(warehouse_grid, "O")
  let walls = grid.find_in_grid(warehouse_grid, "#")

  let moves_list =
    moves
    |> string.replace("\n", "")
    |> string.to_graphemes
    |> list.map(fn(move) {
      case move {
        "^" -> North
        "v" -> South
        "<" -> West
        ">" -> East
        _ -> panic
      }
    })

  Warehouse(
    grid: warehouse_grid,
    robot_pos: robot_pos,
    boxes_pos: boxes_pos,
    walls: walls,
    moves: moves_list,
  )
}
