import error_response
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder
import simplifile

pub fn solve(path: String) {
  let input = read_input(path) |> result.map(build_map(_))
  use map <- result.map(input)

  let #(visited, loops) = map_path(map)
  let visited_count = visited |> set.size

  #(int.to_string(visited_count), int.to_string(loops |> set.size))
}

fn map_path(map: Map) -> #(Set(Position), Set(Position)) {
  let assert Some(initial_position) = map.initial_position
  map_path_rec(
    map,
    initial_position,
    Up,
    set.new() |> set.insert(initial_position),
    set.new(),
  )
}

type Direction {
  Up
  Down
  Left
  Right
}

type Position {
  Position(row: Int, column: Int)
}

fn map_path_rec(
  map: Map,
  position: Position,
  direction: Direction,
  visited: Set(Position),
  obstacles_that_would_create_loops: Set(Position),
) -> #(Set(Position), Set(Position)) {
  let next_position = next_coords(position, direction)
  let loops = case
    set.contains(visited, next_position),
    is_path_a_loop(
      Map(..map, positions: dict.insert(map.positions, next_position, Obstacle)),
      PositionWithDirection(position, turn_right(direction)),
      PositionWithDirection(position, turn_right(direction)),
    )
  {
    True, _ -> obstacles_that_would_create_loops
    False, True ->
      obstacles_that_would_create_loops |> set.insert(next_position)
    False, False -> obstacles_that_would_create_loops
  }

  let next_location = dict.get(map.positions, next_position)

  case next_location {
    Error(_) -> {
      #(visited, loops)
    }
    Ok(Obstacle) ->
      map_path_rec(map, position, turn_right(direction), visited, loops)
    Ok(Empty) ->
      map_path_rec(
        map,
        next_position,
        direction,
        visited |> set.insert(next_position),
        loops,
      )
  }
}

fn is_path_a_loop(
  map: Map,
  slow_position: PositionWithDirection,
  fast_position: PositionWithDirection,
) -> Bool {
  let next_slow_position = next_position(map, slow_position)
  let next_fast_position =
    next_position(map, fast_position)
    |> option.then(next_position(map, _))

  case next_slow_position, next_fast_position {
    Some(next_slow), Some(next_fast) ->
      case next_slow == next_fast {
        True -> True
        False -> is_path_a_loop(map, next_slow, next_fast)
      }
    None, _ | _, None -> False
  }
}

fn next_position(map: Map, current_position: PositionWithDirection) {
  let next_position =
    next_coords(current_position.position, current_position.direction)
  let next_location = dict.get(map.positions, next_position)

  case next_location {
    Error(_) -> {
      None
    }
    Ok(Obstacle) -> {
      Some(PositionWithDirection(
        current_position.position,
        turn_right(current_position.direction),
      ))
    }
    Ok(Empty) -> {
      Some(PositionWithDirection(next_position, current_position.direction))
    }
  }
}

type PositionWithDirection {
  PositionWithDirection(position: Position, direction: Direction)
}

fn turn_right(direction: Direction) -> Direction {
  case direction {
    Up -> Right
    Down -> Left
    Left -> Up
    Right -> Down
  }
}

fn next_coords(current_position: Position, direction: Direction) -> Position {
  case direction {
    Up -> Position(current_position.row - 1, current_position.column)
    Down -> Position(current_position.row + 1, current_position.column)
    Left -> Position(current_position.row, current_position.column - 1)
    Right -> Position(current_position.row, current_position.column + 1)
  }
}

fn read_input(path: String) {
  path
  |> simplifile.read
  |> result.map(fn(file) {
    file
    |> string.split("\n")
    |> list.map(fn(line) { line |> string.split("") })
  })
  |> result.map_error(fn(_e) { error_response.FileError })
}

type Location {
  Obstacle
  Empty
}

type Map {
  Map(positions: Dict(Position, Location), initial_position: Option(Position))
}

fn build_map(grid: List(List(String))) -> Map {
  grid
  |> yielder.from_list
  |> yielder.index
  |> yielder.fold(Map(dict.new(), None), fn(map, row) {
    let #(row_locations, row_index) = row
    row_locations
    |> yielder.from_list
    |> yielder.index
    |> yielder.fold(map, fn(map, location) {
      let #(location, column_index) = location
      let position = Position(row_index, column_index)
      case location {
        "#" ->
          Map(..map, positions: dict.insert(map.positions, position, Obstacle))
        "^" ->
          Map(
            positions: dict.insert(map.positions, position, Empty),
            initial_position: Some(Position(row_index, column_index)),
          )
        _ -> Map(..map, positions: dict.insert(map.positions, position, Empty))
      }
    })
  })
}
