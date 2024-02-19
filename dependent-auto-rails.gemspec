# frozen_string_literal: true

require_relative "lib/dependent-auto-rails/version"

Gem::Specification.new do |spec|
  spec.name = "dependent-auto-rails"
  spec.version = DependentAutoRails::VERSION
  spec.authors = ["Joshua Young"]
  spec.email = ["djry1999@gmail.com"]

  spec.summary = "Automatically and safely decides between :destroy and :delete / :delete_all for your Rails associations."
  spec.homepage = "https://github.com/joshuay03/dependent-auto-rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/joshuay03/dependent-auto-rails/CHANGELOG.md"

  spec.files = Dir["**/*.{md,txt}", "{lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~> 7"

  spec.add_development_dependency "sqlite3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
