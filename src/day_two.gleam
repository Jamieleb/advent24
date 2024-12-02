import error_response
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn solve(path: String) {
  let input =
    path
    |> simplifile.read
    |> result.map(parse_input)
    |> result.map_error(fn(_e) { error_response.FileError })

  use reports <- result.map(input)

  let part_one = list.count(reports, is_report_safe(_, False))
  let part_two = list.count(reports, is_report_safe(_, True))

  #(int.to_string(part_one), int.to_string(part_two))
}

fn parse_input(input: String) {
  let lines = string.split(input, "\n")

  lines
  |> list.map(fn(s) { string.split(s, on: " ") })
  |> list.filter(fn(ls) { list.length(ls) > 1 })
}

type Direction {
  Increasing
  Decreasing
  Unknown
}

fn is_report_safe(report: List(String), allow_problem_dampner: Bool) -> Bool {
  let is_safe = is_report_safe_rec(report, Unknown)
  case is_safe, allow_problem_dampner {
    False, True -> is_report_safe_with_dampner(report)
    s, _ -> s
  }
}

fn is_report_safe_rec(report: List(String), direction: Direction) {
  let is_safe_result = case report {
    [] -> Ok(True)
    [_last] -> Ok(True)
    [first, second, ..tail] ->
      result.flatten({
        use first_int <- result.map(int.base_parse(first, 10))
        use second_int <- result.map(int.base_parse(second, 10))

        let diff = second_int - first_int

        case diff, direction {
          d, _ if d == 0 || d > 3 || d < -3 -> False
          d, Increasing if d > 0 ->
            is_report_safe_rec([second, ..tail], Increasing)
          d, Decreasing if d < 0 ->
            is_report_safe_rec([second, ..tail], Decreasing)
          d, Unknown if d > 0 ->
            is_report_safe_rec([second, ..tail], Increasing)
          d, Unknown if d < 0 ->
            is_report_safe_rec([second, ..tail], Decreasing)
          _, _ -> False
        }
      })
  }

  case is_safe_result {
    Ok(s) -> s
    Error(_) -> panic as "Error in is_report_safe_rec"
  }
}

fn is_report_safe_with_dampner(report: List(String)) {
  is_report_safe_with_dampner_rec([], report)
}

fn is_report_safe_with_dampner_rec(head: List(String), tail: List(String)) {
  case head, tail {
    [], [] -> panic as "invalid empty report encountered"
    head, [first, ..rest] -> {
      let is_safe = is_report_safe_rec(list.flatten([head, rest]), Unknown)

      case is_safe {
        True -> True
        False ->
          is_report_safe_with_dampner_rec(list.flatten([head, [first]]), rest)
      }
    }
    _, [] -> False
  }
}
