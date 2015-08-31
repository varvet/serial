require 'spec_helper'
require 'ostruct'

describe Serial do
  it 'has a version number' do
    expect(Serial::VERSION).not_to be nil
  end

  it 'does something useful' do
    kim = OpenStruct.new({ id: 1, name: "Kim" })
    jonas = OpenStruct.new({ id: 2, name: "Jonas" })
    project = OpenStruct.new({
      id: 13,
      name: "ProjectPuzzle",
      description: "ProjectPuzzle is our own product",
      client: OpenStruct.new({
        id: 5,
        name: "Elabs AB"
      }),
      people: [kim, jonas],
      assignments: [
        OpenStruct.new({ id: 1, duration: "forever", person: kim }),
        OpenStruct.new({ id: 2, duration: "forever ever", person: jonas }),
      ]
    })

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

      h.map(:people, project.people, &PersonSerializer)

      h.map(:assignments, project.assignments) do |h, assignment|
        h.attribute(:id, assignment.id)
        h.attribute(:duration, assignment.duration)

        h.attribute(:person, assignment.person, &PersonSerializer)
      end

    end

    expect(ProjectSerializer.call(project)).to eq({
      "id" => 13,
      "projectName" => "ProjectPuzzle",
      "description" => "ProjectPuzzle is our own product",
      "client" => {
        "id" => 5,
        "name" => "Elabs AB"
      },
      "people" => [
        {
          "id" => 1,
          "name" => "Kim"
        },
        {
          "id" => 2,
          "name" => "Jonas"
        }
      ],
      "assignments" => [
        {
          "id" => 1,
          "duration" => "forever",
          "person" => {
            "id" => 1,
            "name" => "Kim"
          }
        },
        {
          "id" => 2,
          "duration" => "forever ever",
          "person" => {
            "id" => 2,
            "name" => "Jonas"
          }
        }
      ]
    })
  end
end
