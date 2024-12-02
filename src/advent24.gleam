import argv
import day_one
import day_two
import error_response
import gleam/io

pub fn main() {
  let result = case argv.load().arguments {
    ["dayOne", path] -> day_one.solve(path)
    ["dayTwo", path] -> day_two.solve(path)
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
