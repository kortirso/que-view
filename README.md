# Que::View
Rails engine inspired by [Que::Web](https://github.com/statianzo/que-web) for [Que](https://github.com/que-rb/que) job queue.
SQL queries came from Que::Web, some styling from there too.
Benefits for using this one: independent from Sinatra (que-web based on Sinatra)

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

## TODO

- [X] rescheduling jobs
- [X] deleting jobs
- [ ] better styles for UI
- [X] rendering running jobs
- [ ] searching/filtering through jobs by name, queue
- [X] pagination for jobs list page
- [ ] tests

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
