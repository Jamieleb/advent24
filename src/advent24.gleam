import argv
import day_five
import day_four
import day_one
import day_six
import day_three
import day_two
import error_response
import gleam/io

pub fn main() {
  let result = case argv.load().arguments {
    ["dayOne", path] -> day_one.solve(path)
    ["dayTwo", path] -> day_two.solve(path)
    ["dayThree", path] -> day_three.solve(path)
    ["dayFour", path] -> day_four.solve(path)
    ["dayFive", path] -> day_five.solve(path)
    ["daySix", path] -> day_six.solve(path)
    _ -> {
      io.println("Please provide a day number and a path to the input file")
      Error(error_response.InvalidArguments)
    }
  }

  case result {
    Ok(output) -> {
      io.println("part one: " <> output.0)
      io.println("part two: " <> output.1)
    }
    _ -> Nil
  }
}
