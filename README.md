# Serial

[![Build Status](https://img.shields.io/travis/elabs/serial.svg)](http://travis-ci.org/elabs/serial)
[![Dependency Status](https://img.shields.io/gemnasium/elabs/serial.svg)](https://gemnasium.com/elabs/serial)
[![Code Climate](https://img.shields.io/codeclimate/github/elabs/serial.svg)](https://codeclimate.com/github/elabs/serial)
[![Gem Version](https://img.shields.io/gem/v/serial.svg)](http://badge.fury.io/rb/serial)
[![Inline docs](http://inch-ci.org/github/elabs/serial.svg?branch=master&style=shields)](http://inch-ci.org/github/elabs/serial)

*Psst, full documentation can be found at [rubydoc.info/gems/serial](http://www.rubydoc.info/gems/serial)*

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

## Using Serial

*Full reference: [Serial::Serializer](http://www.rubydoc.info/gems/serial/Serial/Serializer)*

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

  h.attribute(:client, project.client) do |h, client|
    h.attribute(:id, client.id)
    h.attribute(:name, client.name)
  end

  h.attribute(:person, assignment.person, &PersonSerializer)

  h.map(:assignments, project.assignments) do |h, assignment|
    h.attribute(:id, assignment.id)
    h.attribute(:duration, assignment.duration)
  end
end

# app/controllers/project_controller.rb
def show
  project = Project.find(…)
  render json: ProjectSerializer.call(self, project) # { "id" => …, "projectName" => …, "client" => { … }, … }
end
```

### Serializing a single object

``` ruby
project = Project.find(…)
context = self
ProjectSerializer.call(context, project) # => { … }
```

### Serializing an array

``` ruby
project = Project.all
context = self
ProjectSerializer.map(context, project) # => [{ … }, …]
```

### Serializer composition

``` ruby
ProjectSerializer = Serial::Serializer.new do |h, project|
  h.attribute(:owner, project.owner, &PersonSerializer)
  h.map(:people, project.people, &PersonSerializer)
end
```

## The DSL

*Full reference: [Serial::HashBuilder](http://www.rubydoc.info/gems/serial/Serial/HashBuilder), [Serial::ArrayBuilder](http://www.rubydoc.info/gems/serial/Serial/ArrayBuilder)*

- *All keys are turned into strings.*
- *There is no automatic camel-casing. You name your keys the way you want them.*

### Simple attributes

``` ruby
ProjectSerializer = Serial::Serializer.new do |h, project|
  h.attribute(:id, project.id)
  h.attribute(:displayName, project.display_name)
end
```

### Nested attributes

``` ruby
ProjectSerializer = Serial::Serializer.new do |h, project|
  h.attribute(:owner, project.owner) do |h, owner|
    h.attribute(:name, owner.name)
  end
end
```

### Collections

`#map` is a convenient method for serializing lists of items.

``` ruby
ProjectSerializer = Serial::Serializer.new do |h, project|
  h.map(:assignments, project.assignments) do |h, assignment|
    h.attribute(:id, assignment.id)
    h.attribute(:duration, assignment.duration)
  end
end
```

The low-level interface powering `#map` is `#collection`.

``` ruby
ProjectSerializer = Serial::Serializer.new do |h, project|
  h.collection(:indices) do |l|
    l.element { |h| h.attribute(…)  }
    l.element { |h| h.attribute(…)  }

    l.collection do |l|
      l.element { … }
      l.element { … }
    end
  end # => [{…}, {…}, [{…}, {…}]]
end
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
