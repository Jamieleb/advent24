import gleam/list
import gleam/result
import gleam/string
import glearray
import utils/read_file

pub fn solve(path: String) {
  let parsed_input =
    read_file.read_file(path)
    |> result.map(prepare_input)

  use input <- result.map(parsed_input)

  let part_one = word_search_rec(input, 0, 0, 0)

  part_one
}

fn word_search_rec(input, total, x, y) {
  let row = glearray.get(input, y)

  case row {
    Ok(r) ->
      word_search_rec(input, total + check_row(input, r, x, y, 0), x, y + 1)
    Error(_) -> total
  }
}

fn check_row(input, row, x, y, total) {
  let char = glearray.get(row, x)

  case char {
    Ok(c) -> {
      let total_from_current = xmas_from_char(input, x, y, c)
      check_row(input, row, x + 1, y, total + total_from_current)
    }
    Error(_) -> total
  }
}

fn prepare_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(s) { s |> string.split("") |> glearray.from_list })
  |> glearray.from_list
}

fn check_for_xmas(
  input: glearray.Array(glearray.Array(String)),
  x: Int,
  y: Int,
  direction: Direction,
  last_char: String,
) -> Result(Bool, Nil) {
  let #(next_x, next_y) = case direction {
    Up -> #(x, y - 1)
    Down -> #(x, y + 1)
    Left -> #(x - 1, y)
    Right -> #(x + 1, y)
    UpLeft -> #(x - 1, y - 1)
    UpRight -> #(x + 1, y - 1)
    DownLeft -> #(x - 1, y + 1)
    DownRight -> #(x + 1, y + 1)
  }

  let next_char = get_next_char(last_char)

  get_char(input, next_x, next_y)
  |> result.try(fn(char) {
    case char {
      c if c == next_char ->
        case c {
          "S" -> Ok(True)
          _ -> check_for_xmas(input, next_x, next_y, direction, c)
        }
      _ -> Ok(False)
    }
  })
}

fn xmas_from_char(input, x, y, char) {
  case char {
    "X" ->
      check_all_directions(input, x, y)
      |> list.fold(0, fn(acc, cur) {
        case cur {
          Ok(True) -> acc + 1
          _ -> acc
        }
      })
    _ -> 0
  }
}

fn check_all_directions(input, x, y) {
  [
    check_for_xmas(input, x, y, Up, "X"),
    check_for_xmas(input, x, y, Down, "X"),
    check_for_xmas(input, x, y, Left, "X"),
    check_for_xmas(input, x, y, Right, "X"),
    check_for_xmas(input, x, y, UpLeft, "X"),
    check_for_xmas(input, x, y, UpRight, "X"),
    check_for_xmas(input, x, y, DownLeft, "X"),
    check_for_xmas(input, x, y, DownRight, "X"),
  ]
}

fn get_char(input, x, y) {
  glearray.get(input, y)
  |> result.try(fn(row) { glearray.get(row, x) })
}

fn get_next_char(last_char: String) {
  case last_char {
    "X" -> "M"
    "M" -> "A"
    "A" -> "S"
    _ -> "X"
  }
}

type Direction {
  Up
  Down
  Left
  Right
  UpLeft
  UpRight
  DownLeft
  DownRight
}
