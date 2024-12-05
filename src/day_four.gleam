import day_four_part_one
import error_response
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn solve(path: String) {
  use input <- result.try(get_input(path))

  use part_one_result <- result.map(day_four_part_one.solve(path))

  let part_two_result = input |> part_two

  #(int.to_string(part_one_result), int.to_string(part_two_result))
}

fn get_input(path: String) {
  path
  |> simplifile.read
  |> result.map(string.split(_, "\n"))
  |> result.map(list.map(_, string.split(_, "")))
  |> result.map_error(fn(_e) { error_response.FileError })
}

fn part_two(data: List(List(String))) {
  let windows =
    data
    |> process_rows_into_window(3)

  let total =
    windows
    |> list.map(list.map(_, check_window))
    |> list.map(int.sum(_))
    |> int.sum

  total
}

fn process_rows_into_window(rows: List(List(String)), window_size: Int) {
  let windows_rows = list.window(rows, window_size)

  windows_rows
  |> list.map(get_grid(_, []))
}

fn get_grid(
  three_rows: List(List(String)),
  existing_grid: List(List(List(String))),
) {
  let assert [r1, r2, r3] = three_rows

  case r1, r2, r3 {
    [r1c1, r1c2, r1c3, ..r1_rest],
      [r2c1, r2c2, r2c3, ..r2_rest],
      [r3c1, r3c2, r3c3, ..r3_rest]
    -> {
      let new_grid = [
        [r1c1, r1c2, r1c3],
        [r2c1, r2c2, r2c3],
        [r3c1, r3c2, r3c3],
      ]
      get_grid(
        [
          [r1c2, r1c3, ..r1_rest],
          [r2c2, r2c3, ..r2_rest],
          [r3c2, r3c3, ..r3_rest],
        ],
        [new_grid, ..existing_grid],
      )
    }
    _, _, _ -> existing_grid
  }
}

fn check_window(window: List(List(String))) {
  case window {
    [["M", _, "M"], [_, "A", _], ["S", _, "S"]]
    | [["M", _, "S"], [_, "A", _], ["M", _, "S"]]
    | [["S", _, "M"], [_, "A", _], ["S", _, "M"]]
    | [["S", _, "S"], [_, "A", _], ["M", _, "M"]] -> 1
    _ -> 0
  }
}
