# re_expand

* Generates all the text strings that match the
given regexp.

    `"(a|b)(1|2)"` => `["a1", "a2", "b1", "b2"]`

* If a filter pattern is given,
the output is filtered by the pattern.

## Install

    $ gem install re_expand

## Usage

    require 're_expand'
    "test (a|b|c)".expand { |s,a|
      puts s
    }
    # "test a",  "test b", ...
    "(a|b)(1|2)".expand
    # => ['a1', 'a2', 'b1', 'b2']

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/masui/expand_ruby](https://github.com/masui/expand_ruby).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

