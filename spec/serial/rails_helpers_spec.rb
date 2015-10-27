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

class FakeContext
  def person_url(person)
    "/fake/#{person.name.downcase}"
  end
end

describe Serial::RailsHelpers do
  include Serial::RailsHelpers

  def view_context
    self
  end

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
    let(:custom_serializer) do
      Serial::Serializer.new do |h, person|
        h.attribute(:rawrwrwr, person.name)
        h.attribute(:url, person_url(person))
      end
    end

    describe "a single model" do
      let(:person) { FakePerson.create!(name: "Yngve") }

      it "serializes a single person in the controller context" do
        expect(serialize(person)).to eq({ "name" => "Yngve", "url" => "/people/yngve" })
      end

      it "allows overriding the context" do
        expect(serialize(FakeContext.new, person)).to eq({ "name" => "Yngve", "url" => "/fake/yngve" })
      end

      it "accepts the serializer as a block" do
        expect(serialize(person, &custom_serializer)).to eq({ "rawrwrwr" => "Yngve", "url" => "/people/yngve" })
      end

      it "allows overriding the context with an overridden serializer" do
        expect(serialize(FakeContext.new, person, &custom_serializer)).to eq({ "rawrwrwr" => "Yngve", "url" => "/fake/yngve" })
      end
    end

    describe "a list of models" do
      before do
        FakePerson.create!(name: "Yngve")
        FakePerson.create!(name: "Ylva")
      end

      # Using ActiveRecord scope here, it's important.
      let(:people) { FakePerson.order(:name).all }

      it "serializes multiple people in the controller context" do
        expect(serialize(people)).to eq([
          { "name" => "Ylva", "url" => "/people/ylva" },
          { "name" => "Yngve", "url" => "/people/yngve" },
        ])
      end

      it "allows overriding the context" do
        expect(serialize(FakeContext.new, people)).to eq([
          { "name" => "Ylva", "url" => "/fake/ylva" },
          { "name" => "Yngve", "url" => "/fake/yngve" },
        ])
      end

      it "accepts the serializer as a block" do
        expect(serialize(people, &custom_serializer)).to eq([
          { "rawrwrwr" => "Ylva", "url" => "/people/ylva" },
          { "rawrwrwr" => "Yngve", "url" => "/people/yngve" },
        ])
      end

      it "allows overriding the context with an overridden serializer" do
        expect(serialize(FakeContext.new, people, &custom_serializer)).to eq([
          { "rawrwrwr" => "Ylva", "url" => "/fake/ylva" },
          { "rawrwrwr" => "Yngve", "url" => "/fake/yngve" },
        ])
      end
    end
  end
end
