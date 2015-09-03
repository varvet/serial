# Serial

[![Build Status](https://img.shields.io/travis/elabs/serial.svg)](http://travis-ci.org/elabs/serial)
[![Dependency Status](https://img.shields.io/gemnasium/elabs/serial.svg)](https://gemnasium.com/elabs/serial)
[![Code Climate](https://img.shields.io/codeclimate/github/elabs/serial.svg)](https://codeclimate.com/github/elabs/serial)
[![Gem Version](https://img.shields.io/gem/v/serial.svg)](http://badge.fury.io/rb/serial)
[![Inline docs](http://inch-ci.org/github/elabs/serial.svg?branch=master&style=shields)](http://inch-ci.org/github/elabs/serial)

Serial is a short and simple serialization library. Its primary purpose is to generate simple
datastructures from object graphs, in other words to help you serialize your data.

Serial is sponsored by [Elabs][].

[![elabs logo][]][Elabs]

[Elabs]: http://www.elabs.se/
[elabs logo]: ./elabs-logo.png?raw=true

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'serial'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install serial

## Usage

You can set up your serializers like this:

``` ruby
# app/serializers/person_serializer.rb
PersonSerializer = Serial::Serializer.new do |h, person|
  h.attribute(:id, person.id)
  h.attribute(:name, person.name)
end

# app/serializers/project_serializer.rb
ProjectSerializer = Serial::Serializer.new do |h, project|
  h.attribute(:id, project.id)
  h.attribute(:projectName, project.name)
  h.attribute(:description, project.description)

  h.attribute(:client, project.client) do |h, client|
    h.attribute(:id, client.id)
    h.attribute(:name, client.name)
  end

  h.map(:assignments, project.assignments) do |h, assignment|
    h.attribute(:id, assignment.id)
    h.attribute(:duration, assignment.duration)

    # This is how you compose serializers.
    h.attribute(:person, assignment.person, &PersonSerializer)
  end

  h.map(:people, project.people, &PersonSerializer)
end
```

Whenever you need to use them you invoke them like this:

``` ruby
person = Person.find(1)
render json: PersonSerializer.call(self, person)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/elabs/serial. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
