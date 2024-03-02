[![Version](https://img.shields.io/gem/v/dependent-auto-rails)][badges:0-gem]
[![Build](https://img.shields.io/github/actions/workflow/status/joshuay03/dependent-auto-rails/.github/workflows/main.yml?branch=main)][badges:1-workflow]

# dependent-auto-rails

This gem provides a new `dependent` option for ActiveRecord associations, `:auto`. Using this option will automatically select between `:destroy` and `:delete` / `:delete_all` during runtime based on whether or not the associated model has any callbacks defined which would usually be executed as part of the destroy lifecycle. This is useful since `dependent: :destroy` always initialises the associated records in order to execute their callbacks regardless of whether or not there are any defined, but is often the go-to option since it is the safest. This can be expensive if there are many records to destroy.

It is also useful since a model's associations are rarely updated, but it's business logic can change frequently. This means that if destroy callbacks are added or removed on the associated model, the `dependent` option on the parent model's association may need to be updated to reflect this. Using `dependent: :auto` will automatically select the appropriate `dependent` option based on the current state of the model.

If you're looking for a solution with little less magic, check out https://github.com/gregnavis/active_record_doctor's `incorrect_dependent_option` detector.

**NOTE**: The `:auto` option **ONLY** decides between `:destroy` and `:delete` / `:delete_all`. It does not use any of the other `dependent` options:
- `:nullify`
- `:destroy_async`
- `:restrict_with_error`
- `:restrict_with_exception`

**NOTE**: If for some reason the `:auto` option is unable to decide between `:destroy` and `:delete` / `:delete_all`, it will default to `:destroy`.

## Installation

Install the gem and add it to the application's Gemfile by executing:

    $ bundle add dependent-auto-rails

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem installdependent-auto-rails

## Usage

To use this gem, all you need to do is add `dependent: :auto` to your model associations where you would usually use one of:
 - `dependent: :destroy` (`belongs_to`, `has_one`, `has_many`)
 - `dependent: :delete` (`belongs_to`, `has_one`)
 - `dependent: :delete_all` (`has_many`).

```ruby
class Post < ApplicationRecord
  belongs_to :author, dependent: :auto

  has_one :pinned_comment, dependent: :auto

  has_many :comments, dependent: :auto
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joshuay03/dependent-auto-rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/dependent-auto-rails/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dependent::Auto::Rails project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/dependent-auto-rails/blob/main/CODE_OF_CONDUCT.md).

[badges:0-gem]: https://rubygems.org/gems/dependent-auto-rails
[badges:1-workflow]: https://github.com/joshuay03/dependent-auto-rails/blob/main/.github/workflows/main.yml
