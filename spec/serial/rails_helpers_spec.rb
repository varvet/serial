require "active_record"

adapter = if RUBY_ENGINE == "jruby"
  "jdbcsqlite3"
else
  "sqlite3"
end

ActiveRecord::Base.establish_connection(adapter: adapter, database: ":memory:")
ActiveRecord::Schema.define do
  self.verbose = false
  create_table :fake_people, :force => true do |t|
    t.string :name
  end
end

# This should be an active record model for model_name testing on scopes.
class FakePerson < ActiveRecord::Base
end

# This must be a constant, so that it can be looked up using constantize.
FakePersonSerializer = Serial::Serializer.new do |h, person|
  h.attribute(:name, person.name)
  h.attribute(:url, person_url(person))
end

describe Serial::RailsHelpers do
  include Serial::RailsHelpers

  # Simulate having a route helper in the controller scope (self).
  def person_url(person)
    "/people/#{person.name.downcase}"
  end

  around do |example|
    ActiveRecord::Base.connection.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  describe "#serialize" do
    it "serializes a single person in the controller context" do
      person = FakePerson.create!(name: "Yngve")

      expect(serialize(person)).to eq({ "name" => "Yngve", "url" => "/people/yngve" })
    end

    it "serializes multiple people in the controller context" do
      FakePerson.create!(name: "Yngve")
      FakePerson.create!(name: "Ylva")

      # Using ActiveRecord scope here, it's important.
      people = FakePerson.order(:name).all

      expect(serialize(people)).to eq([
        { "name" => "Ylva", "url" => "/people/ylva" },
        { "name" => "Yngve", "url" => "/people/yngve" },
      ])
    end
  end
end
