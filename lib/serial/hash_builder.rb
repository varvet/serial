module Serial
  # @api private
  class HashBuilder < Builder
    def initialize(context)
      @context = context
      @data = {}
    end

    # @api public
    # Declare an attribute.
    #
    # @example without block
    #   h.attribute(:id, 5) # => { "id" => 5 }
    #
    # @example nested attribute, with block
    #   h.attribute(:project, project) do |h, project|
    #     h.attribute(:name, project.name)
    #   end # => { "project" => { "name" => … } }
    #
    # @param [#to_s] key
    # @param value
    # @yield [builder, value] declare nested attribute if block is given
    # @yieldparam builder [HashBuilder] a new builder for the nested property (keep in mind the examples shadow the outer `h` variable)
    # @yieldparam value
    def attribute(key, value = nil, &block)
      value = HashBuilder.build(@context, value, &block) if block
      @data[key.to_s] = value
    end

    def collection(key, &block)
      attribute(key, ArrayBuilder.build(@context, &block))
    end

    def map(key, list, &block)
      collection(key) do |builder|
        list.each do |item|
          builder.element { |element| element.exec(item, &block) }
        end
      end
    end
  end
end
