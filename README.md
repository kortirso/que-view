# Que::View
Rails engine inspired by [Que::Web](https://github.com/statianzo/que-web) for [Que](https://github.com/que-rb/que) job queue.
SQL queries came from Que::Web, some styling from there too.

Benefits for using this one:
- no Sinatra (que-web based on Sinatra),
- no Foundation for styles (and no external styles at all),
- no jQuery (and no java scripts at all),
- Que::Web was last updated 2 years ago.

<img width="1731" alt="Снимок экрана 2024-03-03 в 08 28 09" src="https://github.com/kortirso/que-view/assets/6195394/fdaf315d-6c6e-40ee-a60f-cd740cc7ec93">
<img width="1734" alt="Снимок экрана 2024-03-03 в 08 27 47" src="https://github.com/kortirso/que-view/assets/6195394/e45d334e-7637-41f8-af16-d6a9ac35f263">

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
