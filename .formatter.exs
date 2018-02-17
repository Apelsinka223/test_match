locals_without_parens = [match_r: :*, assert_match: :*, refute_match: :*]

[
  inputs: ["mix.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 100,
  locals_without_parens: locals_without_parens,
  export: [
    [
      locals_without_parens: locals_without_parens
    ]
  ]
]