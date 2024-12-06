pub const left = #(0, -1)
pub const right = #(0, 1)
pub const up = #(1, 0)
pub const down = #(-1, 0)
pub const up_left = #(1, -1)
pub const up_right = #(1, 1)
pub const down_left = #(-1, -1)
pub const down_right = #(-1, 1)

pub fn turn_right(direction: #(Int, Int)) -> #(Int, Int) {
  case direction {
    #(0, -1) -> down
    #(0, 1) -> up
    #(1, 0) -> left
    #(-1, 0) -> right
    _ -> panic
  }
}
