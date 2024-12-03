import error_response
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub fn solve(path: String) {
  use input <- result.map(get_input(path))

  let part_one =
    input
    |> list.map(process_line)
    |> int.sum

  let part_two =
    input
    |> string.concat
    |> split_line_by_do_commands
    |> list.map(process_line)
    |> int.sum

  #(int.to_string(part_one), int.to_string(part_two))
}

fn get_input(path: String) {
  path
  |> simplifile.read
  |> result.map(string.split(_, "\n"))
  |> result.map_error(fn(_e) { error_response.FileError })
}

fn process_line(line: String) -> Int {
  let assert Ok(re) =
    regexp.compile(
      "mul\\((\\d+),(\\d+)\\)",
      with: regexp.Options(case_insensitive: False, multi_line: False),
    )

  let matches = regexp.scan(with: re, content: line)

  sum_match_products(matches)
}

fn sum_match_products(matches: List(regexp.Match)) {
  let products =
    list.map(matches, fn(m) {
      let assert [option.Some(num_one_str), option.Some(num_two_str)] =
        m.submatches

      let assert Ok(num_one) = num_one_str |> int.base_parse(10)
      let assert Ok(num_two) = num_two_str |> int.base_parse(10)

      num_one * num_two
    })

  products |> int.sum
}

fn split_line_by_do_commands(line: String) -> List(String) {
  let do_commands =
    line
    |> string.split("do()")
    |> list.map(fn(s) {
      case string.split(s, "don't()") {
        [dos, ..] -> dos
        [] -> s
      }
    })
  do_commands
}
