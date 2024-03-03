# Que::View
Rails engine inspired by [Que::Web](https://github.com/statianzo/que-web) for [Que](https://github.com/que-rb/que) job queue.
SQL queries came from Que::Web, some styling from there too.

Benefits for using this one:
- no Sinatra (que-web based on Sinatra),
- no Foundation for styles,
- no jQuery,
- Que::Web was last updated 2 years ago.

<img width="1735" alt="Снимок экрана 2024-02-21 в 15 10 35" src="https://github.com/kortirso/que-view/assets/6195394/cd2812c7-abb0-48d9-92d5-4dbef93bcd9e">
<img width="1735" alt="Снимок экрана 2024-02-21 в 15 11 12" src="https://github.com/kortirso/que-view/assets/6195394/8af01e7f-a002-4ef1-aeff-f96fd27c639f">


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'que'
gem 'que-view'
```

And then execute:
```bash
$ bundle install
```

## Configuration

You can configure username/password for production web view.
Add this lines to config/initializers/que_view.rb

```ruby
Que::View.configure do |config|
  config.ui_username = 'username'
  config.ui_password = 'password'
  config.ui_secured_environments = ['production']
end
```

## Usage

Add this line to config/routes.rb

```ruby
mount Que::Web::Engine => '/que_web'
```

Add this line to assets/config/manifest.js

```js
//= link que/view/application.css
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
