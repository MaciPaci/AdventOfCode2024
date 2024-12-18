import utils/directions.{North, South, East, West, NorthEast, SouthEast, SouthWest, NorthWest}
import gleam/result
import gleam/string
import gleam/list
import gleam/dict.{type Dict}
import gleam/deque.{type Deque}
import utils/grid.{type Point, Point}
import utils/parser

pub fn pt_1(plants: Dict(String, List(Point))) {
  plants
  |> dict.to_list
  |> list.flat_map(fn(record) {
    to_regions(record.1, [])
  })
  |> list.unique
  |> list.fold(0, fn(acc, region) {
    acc + calculate_fence_perimeter(region) * list.length(region)
  })
}

fn calculate_fence_perimeter(region: List(Point)) -> Int {
  region
  |> list.fold(0, fn(acc, point) {
    acc + 4 - list.count(region, fn(p) {
      p == directions.step(North, point) ||
      p == directions.step(South, point) ||
      p == directions.step(East, point) ||
      p == directions.step(West, point)
    })
  })
}

fn to_regions(plants: List(Point), regions: List(List(Point))) -> List(List(Point)) {
  case plants {
    [] -> regions
    [plant, ..rest] -> {
      let neighbours = find_neighbours(deque.from_list([plant]), plants, [plant])

      list.append(regions, to_regions(list.filter(rest, fn(p) { !list.contains(neighbours, p) }), list.append(regions, [neighbours])))
    }
}
}

fn find_neighbours(queue: Deque(Point), plants: List(Point), neighbours: List(Point)) -> List(Point) {
  case deque.pop_front(queue) {
    Error(_) -> neighbours
    Ok(#(plant, new_queue)) -> {
      let neighs = list.filter(plants, fn(p) {
        p == directions.step(North, plant) ||
        p == directions.step(South, plant) ||
        p == directions.step(East, plant) ||
        p == directions.step(West, plant)
      })
      |> list.filter(fn(n) {!list.contains(neighbours, n)})

      let new_neighbours = list.append(neighbours, neighs)
      let new_plants = list.filter(plants, fn(n) { !list.contains(new_neighbours, n) })
      find_neighbours(list.fold(neighs, new_queue, fn(acc, n) {deque.push_back(acc, n)}), new_plants, new_neighbours)
    }
  }
}

pub fn pt_2(plants: Dict(String, List(Point))) {
  plants
  |> dict.to_list
  |> list.flat_map(fn(record) {
    to_regions(record.1, [])
  })
  |> list.unique
  |> list.fold(0, fn(acc, region) {
    acc + count_corners(region) * list.length(region)
  })
}

fn count_corners(region: List(Point)) -> Int {
  region
  |> list.fold(0, fn(acc, plant) {
    let ne = list.filter(region, fn(p) {p == directions.step(NorthEast, plant)})
    let se = list.filter(region, fn(p) {p == directions.step(SouthEast, plant)})
    let nw = list.filter(region, fn(p) {p == directions.step(NorthWest, plant)})
    let sw = list.filter(region, fn(p) {p == directions.step(SouthWest, plant)})
    let east = list.filter(region, fn(p) {p == directions.step(East, plant)})
    let west = list.filter(region, fn(p) {p == directions.step(West, plant)})
    let north = list.filter(region, fn(p) {p == directions.step(North, plant)})
    let south = list.filter(region, fn(p) {p == directions.step(South, plant)})

    let vertical = list.filter(region, fn(p) {
      p == directions.step(North, plant) || p == directions.step(South, plant)
    })
    let horizontal = list.filter(region, fn(p) {
      p == directions.step(East, plant) || p == directions.step(West, plant)
    })

    case list.length(vertical), list.length(horizontal) {
      0, 0 -> acc + 4
      1, 1 -> {
        case list.length(north), list.length(east) {
          1, 1 -> acc + 2 - list.length(ne)
          1, 0 -> acc + 2 - list.length(nw)
          0, 1 -> acc + 2 - list.length(se)
          0, 0 -> acc + 2 - list.length(sw)
          _, _ -> panic
        }
      }
      0, 1 | 1, 0 -> acc + 2
      2, 1 -> {
        case list.length(east), list.length(west) {
          1, _ -> acc + 2 - list.length(ne) - list.length(se)
          _, 1 -> acc + 2 - list.length(nw) - list.length(sw)
          _, _ -> panic
        }
      }
      1,2 -> {
        case list.length(north), list.length(south) {
          1, _ -> acc + 2 - list.length(ne) - list.length(nw)
          _, 1 -> acc + 2 - list.length(sw) - list.length(se)
          _, _ -> panic
        }
      }
      2, 2 -> acc + 4 - list.length(ne) - list.length(se) - list.length(nw) - list.length(sw)
      _, _ -> acc
    }
  })
}

pub fn parse(input: String) -> Dict(String, List(Point)) {
  parser.parse_lines(input)
  |> list.map(fn(line) {
    string.to_graphemes(line)
  })
  |> grid.to_grid(0, 0, dict.new())
  |> dict.to_list
  |> list.fold(dict.new(), fn(acc, record) {
    let #(point, value) = record
    let current = dict.get(acc, value) |> result.unwrap([])
    dict.insert(acc, value, list.append(current, [point]))
  })
}
