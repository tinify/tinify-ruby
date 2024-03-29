[![Gem](https://img.shields.io/gem/v/tinify)](https://rubygems.org/gems/tinify)
[![MIT License](http://img.shields.io/badge/license-MIT-green.svg) ](https://github.com/tinify/tinify-java/blob/main/LICENSE)
[![Ruby CI](https://github.com/tinify/tinify-ruby/actions/workflows/ci-cd.yaml/badge.svg)](https://github.com/tinify/tinify-ruby/actions/workflows/ci-cd.yaml)

# Tinify API client for Ruby

Ruby client for the Tinify API, used for [TinyPNG](https://tinypng.com) and [TinyJPG](https://tinyjpg.com). Tinify compresses your images intelligently. Read more at [http://tinify.com](http://tinify.com).

## Documentation

[Go to the documentation for the Ruby client](https://tinypng.com/developers/reference/ruby).

## Installation

Install the API client:

```
gem install tinify
```

Or add this line to your application's Gemfile:

```ruby
gem "tinify"
```

## Usage

```ruby
require "tinify"
Tinify.key = "YOUR_API_KEY"

Tinify.from_file("unoptimized.png").to_file("optimized.png")
```

## Running tests

```
bundle install
rake
```

### Integration tests

```
bundle install
TINIFY_KEY=$YOUR_API_KEY rake integration
```

## License

This software is licensed under the MIT License. [View the license](LICENSE).
