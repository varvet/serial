# Serial

Serial is a serialization library. Its primary purpose is to generate simple
datastructures from object graphs.

## Example

You can set up your serializers like this:

``` ruby
# app/serializers/person_serializer.rb
PersonSerializer = Serializer.new do |h, person|
  h.attribute(:id, person.id)
  h.attribute(:name, person.name)
end

# app/serializers/project_serializer.rb
ProjectSerializer = Serializer.new do |h, project|
  h.attribute(:id, project.id)
  h.attribute(:project_name, project.name)
  h.attribute(:description, project.description)

  h.attribute(:client, project.client) do |h, client|
    h.attribute(:id, client.id)
    h.attribute(:name, client.name)
  end

  h.map(:people, project.people, &PersonSerializer)

  h.map(:assignments, project.assignments) do |h, assignment|
    h.attribute(:id, assignment.id)
    h.attribute(:duration, assignment.duration)

    h.attribute(:person, assignment.person, &PersonSerializer)
  end
end
```

T

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'serial'
```
