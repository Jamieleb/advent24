import error_response
import gleam/result
import simplifile

pub fn read_file(path: String) {
  path
  |> simplifile.read
  |> result.map_error(fn(_e) { error_response.FileError })
}
