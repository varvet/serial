source "https://rubygems.org"

gemspec

group :development do
  platform :ruby do
    gem "sqlite3"
  end

  platform :jruby do
    gem "jdbc-sqlite3"
    gem "activerecord-jdbcsqlite3-adapter"
  end
end
