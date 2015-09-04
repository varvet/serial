module Serial
  class Serializer
    # Create a new Serializer, using the block as instructions.
    #
    # @example
    #   PersonSerializer = Serial::Serializer.new do |h, person|
    #     h.attribute(:id, person.id)
    #     h.attribute(:name, person.name)
    #   end
    #
    #   PersonSerializer.call(…)
    #
    # @yield [builder, *args]
    # @yieldparam builder [HashBuilder]
    # @yieldparam *args
    def initialize(&block)
      @block = block
    end

    # Serialize an object with this serializer, optionally within a context.
    #
    # @example with context, the serializer block is evaluated inside the context
    #   # app/serializers/person_serializer.rb
    #   PersonSerializer = Serial::Serializer.new do |h, person|
    #     h.attribute(:id, person.id)
    #     h.attribute(:url, people_url(person))
    #   end
    #
    #   # app/controllers/person_controller.rb
    #   def show
    #     person = Person.find(…)
    #     render json: PersonSerializer.call(self, person)
    #   end
    #
    # @example without context, the serializer block is evaluated using normal closure rules
    #   # app/models/person.rb
    #   class Person
    #     Serializer = Serial::Serializer.new do |h, person|
    #       h.attribute(:id, person.id)
    #       h.attribute(:available_roles, available_roles)
    #     end
    #
    #     def self.available_roles
    #       …
    #     end
    #   end
    #
    #   # app/controllers/person_controller.rb
    #   def show
    #     person = Person.find(…)
    #     render json: Person::Serializer.call(person)
    #   end
    #
    # @param context
    # @param value
    # @return [Hash]
    def call(context = nil, value)
      HashBuilder.build(context, value, &@block)
    end

    # Serialize a list of objects with this serializer, optionally within a context.
    #
    # @example
    #   # app/serializers/person_serializer.rb
    #   PersonSerializer = Serial::Serializer.new do |h, person|
    #     h.attribute(:id, person.id)
    #     h.attribute(:url, people_url(person))
    #   end
    #
    #   # app/controllers/person_controller.rb
    #   def index
    #     people = Person.all
    #     render json: PersonSerializer.map(self, people)
    #   end
    #
    # @see #call see #call for an explanation of the context parameter
    # @param (see #call)
    # @return [Array]
    def map(context = nil, list)
      list.map { |item| call(context, item) }
    end

    # Serializer composition!
    #
    # @example
    #   # app/serializers/person_serializer.rb
    #   PersonSerializer = Serial::Serializer.new do |h, person|
    #     h.attribute(:name, person.name)
    #   end
    #
    #   # app/serializers/project_serializer.rb
    #   ProjectSerializer = Serial::Serializer.new do |h, project|
    #     h.attribute(:projectName, project.name)
    #     h.attribute(:owner, project.owner, &PersonSerializer)
    #   end
    #
    # @return [Proc]
    def to_proc
      block = @block
      proc do |builder, *args|
        builder.exec(*args, &block)
      end
    end
  end
end
