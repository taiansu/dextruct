# Dextruct

### Destructing assignment with `<~`

It's so obvious that pattern matching with `=` is _just awesome_. But less then occasionally, we still want some destructing assignment, witout `MatchError`, works like in other languge. `Dextruct` library provides a `<~` operator which imitates similar behavior, with some other goodies.

## Installation

The package can be installed by adding `dextruct` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:dextruct, "~> 0.2.0"}
  ]
end
```

After excute `mix deps.get` command, add `use Dextruct` in your module:
```elixir
def YourModule do
  use Dextruct
end
```

## Destruct assignment

The `<~` operator works on two senarios, `List` and `Map`.

### List
For destructing assignment on `List`, it simply fills up the list on left hand side with filler (`nil` by default).

```elixir
iex> [a, b, c] <~ [1, 2]
[1, 2, nil]

iex> c
nil
```

One of the useful example is use with `Regex`'s optional group matching. Originally it will omit the unmatched groups in the end.
```elixir
iex> Regex.run(~r/(a)?(b)?(c)?(d)?/, "ab")
["ab", "a", "b"]

iex> [matched, a, b, c, d] <~ Regex.run(~r/(a)?(b)?(c)?(d)?/, "ab")
["ab", "a", "b", nil, nil]
```

### Map
Destructing assignment on `Map`, then as well, fill the keys missing in the right hand side map,
with filler.
```elixir
iex> %{a: a, b: b, c: c} <~ %{a: 1}
iex> a
1
iex> b
nil
iex> c
nil
```

### Different filler

You can specify the filler by `fill` option while `use Dextruct`. That means you can only have one filler for each module.

```elixir
def YourModule do
  use Dextruct, fill: 0
end
```

## Map short-hand literal

Dextractor also come with a short-hand literal for `Map`, which is `sigil_m`.
```elixir
iex> ~m{a, b, c: foo} = %{a: 1, b: 2, c: 3}
%{a: 1, b: 2, c: 3}
```

It works well with `<~`, of course.
```elixir
iex> ~m{a, b, c: foo} <~ %{a: 1}
iex> a
1
iex> b
nil
iex> foo
nil
```

### Exclude `sigil_m`
To be honest, if you use shorthand map literal quite often, without change the binding variable in between, i.e.,  `c: foo` in the previous code demo, you should consider using [ShortMaps](https://github.com/whatyouhide/short_maps) instead. Which is more like the consensus of the community for now.

To do so, you'll like to `except` the `sigil_m` while using `Dextruct`.
```elixir
defmodule YourModule do
  use Dextruct, except: [sigil_m: 2]
end
```

Actually, the `sigil_m` comes with `Dextruct` will be exclude by default or even deprecate, once the
`ShortMap` literal becomes the de facto standard anytime in the future.

## Is it any good?

Hopefully.

## License

Apache 2
