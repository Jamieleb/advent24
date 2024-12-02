import error_response
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn solve(path: String) {
  use input <- result.map(
    path
    |> simplifile.read
    |> result.map(split_string_into_two_lists)
    |> result.map_error(fn(_err) { error_response.FileError }),
  )
  let #(list_one, list_two) = input

  let part_one = day_one_part_one(list_one, list_two)
  let part_two = day_one_part_two(list_one, list_two)

  #(int.to_string(part_one), int.to_string(part_two))
}

fn day_one_part_one(list_one, list_two) {
  let #(sorted_one, sorted_two) = #(
    list.sort(list_one, by: string.compare),
    list.sort(list_two, by: string.compare),
  )

  let sum =
    list.zip(sorted_one, sorted_two)
    |> list.map(fn(lists) {
      let a = int.base_parse(lists.0, 10)
      let b = int.base_parse(lists.1, 10)
      case a, b {
        Ok(a), Ok(b) -> {
          Ok(int.absolute_value(a - b))
        }
        _, _ -> Error("Could not parse")
      }
    })
    |> list.fold(0, fn(acc, diff) {
      case diff {
        Ok(d) -> acc + d
        Error(_) -> acc
      }
    })

  sum
}

fn day_one_part_two(list_one, list_two) {
  list_one
  |> list.fold(0, fn(sum, item) {
    let count = list.count(list_two, fn(i) { i == item })

    let value = int.base_parse(item, 10)

    let score = case value {
      Ok(v) -> v * count
      _ -> 0
    }
    sum + score
  })
}

fn split_string_into_two_lists(input: String) {
  let lines = string.split(input, "\n")

  lines
  |> list.fold(#([], []), fn(acc, line) {
    let #(a, b) = case
      string.split(line, "   ")
      |> list.map(fn(s) { string.trim(s) })
    {
      [a, b] -> #(a, b)
      _ -> #("", "")
    }

    #([a, ..acc.0], [b, ..acc.1])
  })
}
