module Serial
  class HashBuilder < Builder
    # @api private
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
    # @yieldparam builder [HashBuilder] (keep in mind the examples shadow the outer `h` variable)
    # @yieldparam value
    def attribute(key, value = nil, &block)
      value = HashBuilder.build(@context, value, &block) if block
      @data[key.to_s] = value
    end

    # @api public
    # Declare a collection attribute. This is a low-level method, see {#map} instead.
    #
    # @example
    #   h.collection(:people) do |l|
    #     l.element do |h|
    #       h.attribute(…)
    #     end
    #     l.element do |h|
    #       h.attribute(…)
    #     end
    #     l.collection do |l|
    #       l.element do |h|
    #         h.attribute(…)
    #       end
    #     end
    #   end # => { "people" => [{…}, {…}, [{…}]] }
    #
    # @see ArrayBuilder
    # @param [#to_s] key
    # @yieldparam builder [ArrayBuilder]
    def collection(key, &block)
      attribute(key, ArrayBuilder.build(@context, &block))
    end

    # @api public
    # Declare a collection attribute from a list of values.
    #
    # @example
    #   h.map(:people, project.people) do |h, person|
    #     h.attribute(:name, person.name)
    #   end # => { "people" => [{ "name" => … }] }
    #
    # @see #collection
    # @param [#to_s] key
    # @param [#each] list
    # @yield [builder, value] yields each value from list to build an array of hashes
    # @yieldparam builder [HashBuilder]
    # @yieldparam value
    def map(key, list, &block)
      collection(key) do |builder|
        list.each do |item|
          builder.element do |element|
            element.exec(item, &block)
          end
        end
      end
    end
  end
end
