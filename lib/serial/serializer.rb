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

    # Invoke a Serializer, optionally passing it a context to be evaluated in.
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
    # @example (TODO) without context, the serializer block is evaluated using normal closure rules
    #
    def call(context = nil, value)
      HashBuilder.build(context, value, &@block)
    end

    def map(context = nil, list)
      list.map { |item| call(context, item) }
    end

    def to_proc
      block = @block
      proc do |builder, *args|
        builder.exec(*args, &block)
      end
    end
  end
end
