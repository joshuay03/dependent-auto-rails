# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# standard:disable Bundler/DuplicatedGem
if (rails_version = ENV["RAILS_VERSION"]) && (ruby_version = ENV["RUBY_VERSION"])
  gem "activerecord", rails_version

  rails_gem_version = Gem::Version.new(rails_version)
  ruby_gem_version = Gem::Version.new(ruby_version) unless ruby_version == "head"

  if rails_gem_version >= Gem::Version.new("8.0")
    gem "sqlite3", ">= 2.1"
  else
    gem "sqlite3", ">= 1.4"
  end

  if rails_gem_version == Gem::Version.new("7.2") && (!ruby_gem_version || ruby_gem_version >= Gem::Version.new("4.0"))
    gem "benchmark"
  end
else
  gem "sqlite3"
end
# standard:enable Bundler/DuplicatedGem

gem "rake"

gem "minitest"

gem "standard"
