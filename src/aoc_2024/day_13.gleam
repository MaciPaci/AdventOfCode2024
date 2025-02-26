import utils/tuple
import gleam/result
import gleam/int
import gleam/list
import gleam/string
import gleam/regexp

pub type Button {
  Button(x: Int, y: Int)
}
pub type Prize {
  Prize(x: Int, y: Int)
}

pub fn pt_1(input: List(#(Button, Button, Prize))) {
  input
  |> list.fold(0, fn(acc, machine) {
    machine
    |> calculate_machine
    |> fn(times) {
      acc + 3 * tuple.first(times) + tuple.second(times)
    }
  })
}

fn calculate_machine(machine: #(Button, Button, Prize)) -> #(Int, Int) {
  let #(button_a, button_b, prize) = machine
  let times_b = {button_a.x * prize.y - button_a.y * prize.x} / {button_a.x * button_b.y - button_a.y * button_b.x}
  let times_a = {prize.x - times_b * button_b.x} / {button_a.x}

  case button_a.x * times_a + button_b.x * times_b == prize.x
  && button_a.y * times_a + button_b.y * times_b == prize.y {
    True -> #(times_a, times_b)
    False -> #(0, 0)
  }
}

pub fn pt_2(input: List(#(Button, Button, Prize))) {
  input
  |> list.map(fn(machine) {
    let p = machine.2
    #(machine.0, machine.1, Prize(p.x + 10000000000000, p.y + 10000000000000))
  })
  |> list.fold(0, fn(acc, machine) {
    machine
    |> calculate_machine
    |> fn(times) {
      acc + 3 * tuple.first(times) + tuple.second(times)
    }
  })
}

pub fn parse(input: String) -> List(#(Button, Button, Prize)) {
    string.split(input, "\n\n")
    |> list.map(fn(machine) {
      let assert [button_a, button_b, prize] = string.split(machine, "\n")
      let assert [x_a, y_a] = find_matches_for_string(button_a)
      let assert [x_b, y_b] = find_matches_for_string(button_b)
      let assert [x_p, y_p] = find_matches_for_string(prize)
      #(
      Button(x_a, y_a),
      Button(x_b, y_b),
      Prize(x_p, y_p)
      )
    })
}

fn find_matches_for_string(input: String) -> List(Int) {
  let assert Ok(re) = regexp.from_string("\\d+")
  regexp.scan(with: re, content: input)
  |> list.map(fn(match) { match.content |> int.parse |> result.unwrap(0) })
}
