[<img src="https://travis-ci.org/tinify/tinify-ruby.svg?branch=master" alt="Build Status">](https://travis-ci.org/tinify/tinify-ruby)

# Tinify API client for Ruby

Ruby client for the Tinify API. Tinify compresses your images intelligently. Read more at https://tinify.com.

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
