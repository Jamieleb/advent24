import gleam/dict.{type Dict}
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/order
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn solve(path: String) {
  let #(rule_dict, updates_list) = get_input(path)

  let part_one =
    updates_list
    |> list.filter_map(get_mid_elements_from_valid_updates(_, rule_dict))
    |> list.map(fn(s) {
      let assert Ok(num) = int.base_parse(s, 10)
      num
    })
    |> int.sum

  let part_two =
    updates_list
    |> list.filter(fn(update_list) {
      case check_update_list_is_valid(update_list, set.new(), 0, rule_dict) {
        Valid(_) -> False
        Invalid -> True
      }
    })
    |> list.map(list.sort(_, build_update_sorter(rule_dict)))
    |> list.map(fn(ls) {
      let mid = get_mid_element(ls, list.length(ls))
      let assert Ok(num) = int.base_parse(mid, 10)
      num
    })
    |> int.sum

  Ok(#(int.to_string(part_one), int.to_string(part_two)))
}

fn build_update_sorter(rules: Dict(String, Set(String))) {
  let sorter = fn(a: String, b: String) {
    let a_rules = dict.get(rules, a)
    let b_rules = dict.get(rules, b)

    case a_rules {
      Ok(rules) -> {
        case set.contains(rules, b) {
          True -> order.Lt
          False ->
            case b_rules {
              Ok(rules) -> {
                case set.contains(rules, a) {
                  True -> order.Gt
                  False -> order.Eq
                }
              }
              Error(_) -> order.Eq
            }
        }
      }
      Error(_) -> order.Eq
    }
  }

  sorter
}

fn get_mid_element(ls: List(String), length: Int) {
  let assert Ok(mid_pos) = int.divide(length - 1, 2)

  let assert #(_, Some(element)) =
    ls
    |> list.fold_until(#(0, None), fn(acc, elem) {
      let index = acc.0
      case index == mid_pos {
        True -> Stop(#(index, Some(elem)))
        False -> Continue(#(index + 1, None))
      }
    })

  element
}

fn get_mid_elements_from_valid_updates(
  update_list: List(String),
  rule_dict: Dict(String, Set(String)),
) {
  case check_update_list_is_valid(update_list, set.new(), 0, rule_dict) {
    Valid(count) -> {
      Ok(get_mid_element(update_list, count))
    }
    Invalid -> Error(Nil)
  }
}

type Validity {
  Valid(Int)
  Invalid
}

fn check_update_list_is_valid(
  update_list: List(String),
  seen: Set(String),
  count: Int,
  rule_dict: Dict(String, Set(String)),
) {
  let #(page, rest) = case update_list {
    [] -> #(None, [])
    [head, ..tail] -> #(Some(head), tail)
  }

  case page {
    None -> Valid(count)
    Some(p) -> {
      let invalid_prior_pages = dict.get(rule_dict, p)

      case invalid_prior_pages {
        Ok(invalid_pages) -> {
          case set.intersection(invalid_pages, seen) |> set.size {
            0 ->
              check_update_list_is_valid(
                rest,
                set.insert(seen, p),
                count + 1,
                rule_dict,
              )
            _ -> Invalid
          }
        }
        Error(_) ->
          check_update_list_is_valid(
            rest,
            set.insert(seen, p),
            count + 1,
            rule_dict,
          )
      }
    }
  }
}

fn get_input(path: String) {
  let assert Ok(input) = simplifile.read(path)

  let assert [rules, updates] = string.split(input, "\n\n")

  let rule_dict = build_rule_dict(rules)

  let updates_list =
    updates
    |> string.split("\n")
    |> list.map(string.split(_, ","))
    |> list.filter(fn(ls) {
      case ls {
        [""] -> False
        _ -> True
      }
    })

  #(rule_dict, updates_list)
}

fn build_rule_dict(rules: String) {
  let rule_list = string.split(rules, "\n")

  rule_list
  |> list.fold(dict.new(), fn(rule_dict, rule) {
    let assert [key, value] = string.split(rule, "|")
    dict.upsert(rule_dict, key, fn(existing) {
      case existing {
        None -> set.insert(set.new(), value)
        Some(values) -> set.insert(values, value)
      }
    })
  })
}
