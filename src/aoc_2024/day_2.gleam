import gleam/string
import gleam/result
import gleam/int
import gleam/list
import utils/parser
import gleam/order.{type Order}
import gleam/option.{type Option, Some, None}

pub fn pt_1(input: String) {
  let reports = parser.parse_lines(input)
  |> list.map(fn(el) {string.split(el, " ") |> list.map(fn(i) {int.parse(i) |> result.unwrap(0)})})
  count_safe_reports(reports, 0)
}

fn count_safe_reports(reports: List(List(Int)), safe: Int) -> Int {
  case reports {
    [report, ..rest] -> {
      case !does_order_change(report, None) && is_safe(report) {
        True -> count_safe_reports(rest, safe + 1)
        False -> count_safe_reports(rest, safe)
      }
    }
    _ -> safe
  }
}

fn does_order_change(report: List(Int), order: Option(Order)) -> Bool {
  case report {
    [first, second, ..rest] -> {
      case order {
        Some(o) -> {
          case o == int.compare(first, second) {
            True -> does_order_change([second, ..rest], order)
            False -> True
          }
        }
        None -> does_order_change([second, ..rest], Some(int.compare(first, second)))
      }
    }
    _ -> False
  }
}

fn is_safe(report: List(Int)) -> Bool {
  case report {
    [first, second, ..rest] -> {
      case int.absolute_value(first-second) == 1 || int.absolute_value(first-second) == 2  || int.absolute_value(first-second) == 3 {
        True -> is_safe([second, ..rest])
        False -> False
      }
    }
    _ -> True
  }
}

pub fn pt_2(input: String) {
  let reports = parser.parse_lines(input)
  |> list.map(fn(el) {string.split(el, " ") |> list.map(fn(i) {int.parse(i) |> result.unwrap(0)})})
  count_safe_reports_with_removal(reports, 0)
}

fn count_safe_reports_with_removal(reports: List(List(Int)), safe: Int) -> Int {
  case reports {
    [report, ..rest] -> {
      case !does_order_change(report, None) && is_safe(report) {
        True -> count_safe_reports_with_removal(rest, safe + 1)
        False -> {
          case is_safe_after_removal(list.combinations(report, list.length(report) - 1)) {
            True -> count_safe_reports_with_removal(rest, safe + 1)
            False -> count_safe_reports_with_removal(rest, safe)
          }
        }
      }
    }
    _ -> safe
  }
}

fn is_safe_after_removal(combinations: List(List(Int))) -> Bool {
  case combinations {
    [first, ..rest] -> case !does_order_change(first, None) && is_safe(first) {
      True -> True
      False -> is_safe_after_removal(rest)
    }
    _ -> False
  }
}
