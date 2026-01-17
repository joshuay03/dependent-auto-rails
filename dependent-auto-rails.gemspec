# frozen_string_literal: true

require_relative "lib/dependent-auto-rails/version"

Gem::Specification.new do |spec|
  spec.name = "dependent-auto-rails"
  spec.version = DependentAutoRails::VERSION
  spec.authors = ["Joshua Young"]
  spec.email = ["djry1999@gmail.com"]

  spec.summary = "Automatically decides between :destroy and :delete / :delete_all for your Rails associations."
  spec.homepage = "https://github.com/joshuay03/dependent-auto-rails"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.2")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir["**/*.{md,txt}", "{lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 7.2"
end
