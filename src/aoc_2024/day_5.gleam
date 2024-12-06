import gleam/order
import gleam/int
import gleam/result
import gleam/string
import gleam/list
import gleam/dict.{type Dict}
import utils/parser

pub fn pt_1(input: String) {
  let input_lines = input |> parser.parse_lines()
  let rules_lines = input_lines |> list.filter(fn(el) {string.contains(el, "|") && !string.is_empty(el)})
  let updates = input_lines |> list.filter(fn(el) {string.contains(el, ",") && !string.is_empty(el)}) |> list.map(fn(el) {string.split(el, ",")})
  let rules = parse_rules(rules_lines, dict.new())

  find_correct_updates(updates, rules, [])
  |> get_middle_page_number([])
  |> list.fold(0, fn(acc, el) {acc + {int.parse(el) |> result.unwrap(0)}})
}

fn get_middle_page_number(updates: List(List(String)), middle_pages: List(String)) -> List(String) {
  case updates {
    [first, ..rest] -> {
      let pages = list.append(middle_pages, [list.last(list.split(first, list.length(first) / 2 + 1).0) |> result.unwrap("")])
      get_middle_page_number(rest, pages)
    }
    _ -> middle_pages
  }
}

fn find_correct_updates(updates: List(List(String)), rules: Dict(String, List(String)), correct_updates: List(List(String))) -> List(List(String)) {
  case updates{
    [first, ..rest] -> {
      case is_update_correct(first, rules) {
        True -> find_correct_updates(rest, rules, list.append(correct_updates, [first]))
        False -> find_correct_updates(rest, rules, correct_updates)
      }
    }
    _ -> correct_updates
  }
}

fn is_update_correct(update: List(String), rules: Dict(String, List(String))) -> Bool {
  case update {
    [first, ..rest] -> {
      case is_before(rest, dict.get(rules, first) |> result.unwrap(list.new())) {
        True -> is_update_correct(rest, rules)
        False -> False
      }
    }
    _ -> True
  }
}

fn is_before(rest: List(String), page_rules: List(String)) -> Bool {
  case rest {
    [first, ..rest] -> {
      case list.contains(page_rules, first) {
        True -> is_before(rest, page_rules)
        False -> False
      }
    }
    _ -> True
  }
}

fn parse_rules(rules_lines: List(String), rules: Dict(String, List(String))) -> Dict(String, List(String)) {
  case rules_lines {
    [first, ..rest] -> {
      let assert [page, after_page] = first |> string.split("|")
      let page_rules = dict.get(rules, page) |> result.unwrap(list.new())
      let after = dict.insert(rules, page, [after_page, ..page_rules])
      parse_rules(rest, after)
    }
    _ -> rules
  }
}

pub fn pt_2(input: String) {
  let input_lines = input |> parser.parse_lines()
  let rules_lines = input_lines |> list.filter(fn(el) {string.contains(el, "|") && !string.is_empty(el)})
  let updates = input_lines |> list.filter(fn(el) {string.contains(el, ",") && !string.is_empty(el)}) |> list.map(fn(el) {string.split(el, ",")})
  let rules = parse_rules(rules_lines, dict.new())
  let rule_pairs = parse_rules_into_pairs(rules_lines, list.new())

  find_incorrect_updates(updates, rules, [])
  |> fix_incorrect_updates(rule_pairs, [])
  |> get_middle_page_number([])
  |> list.fold(0, fn(acc, el) {acc + {int.parse(el) |> result.unwrap(0)}})
}

fn parse_rules_into_pairs(rules_lines: List(String), rules: List(#(String, String))) -> List(#(String, String)) {
  case rules_lines {
    [first, ..rest] -> {
      let assert [before, after] = first |> string.split("|")
      let after = list.append(rules, [#(before, after)])
      parse_rules_into_pairs(rest, after)
    }
    _ -> rules
  }
}

fn parse_rules_before(rules_lines: List(String), rules: Dict(String, List(String))) -> Dict(String, List(String)) {
  case rules_lines {
    [first, ..rest] -> {
      let assert [before_page, page] = first |> string.split("|")
      let page_rules = dict.get(rules, page) |> result.unwrap(list.new())
      let before = dict.insert(rules, page, [before_page, ..page_rules])
      parse_rules_before(rest, before)
    }
    _ -> rules
  }
}

fn fix_incorrect_updates(updates: List(List(String)), rules: List(#(String, String)), fixed_updates: List(List(String))) -> List(List(String)) {
  case updates {
    [first, ..rest] -> {
      let fixed_update = fix_update(first, rules)
      let fixed_updates = list.append(fixed_updates, [fixed_update])
      fix_incorrect_updates(rest, rules, fixed_updates)
    }
    _ -> fixed_updates
  }
}

fn fix_update(update: List(String), rules: List(#(String, String))) -> List(String) {
  list.sort(update, fn(a, b) {
    case list.contains(rules, #(a, b)) {
      True -> order.Lt
      False -> order.Gt
    }
  })
}

fn find_incorrect_updates(updates: List(List(String)), rules: Dict(String, List(String)), incorrect_updates: List(List(String))) -> List(List(String)) {
  case updates{
    [first, ..rest] -> {
      case is_update_correct(first, rules) {
        True -> find_incorrect_updates(rest, rules, incorrect_updates)
        False -> find_incorrect_updates(rest, rules, list.append(incorrect_updates, [first]))
      }
    }
    _ -> incorrect_updates
  }
}
