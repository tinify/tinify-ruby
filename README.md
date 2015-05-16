[<img src="https://travis-ci.org/TinyPNG/tinify-ruby.svg?branch=master" alt="Build Status">](https://travis-ci.org/TinyPNG/tinify-ruby)

# Tinify API client for Ruby

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

## License

This software is licensed under the MIT License. [View the license](LICENSE).
