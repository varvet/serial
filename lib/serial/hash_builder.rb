module Serial
  # A builder for building hashes. You most likely just want to look at the
  # public API methods in this class.
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
    # @param key [#to_s]
    # @param value
    # @yield [builder, value] declare nested attribute if block is given
    # @yieldparam builder [HashBuilder] (keep in mind the examples shadow the outer `h` variable)
    # @yieldparam value
    # @raise [DuplicateKeyError] if the same key has already been defined.
    def attribute(key, value = nil, &block)
      check_duplicate_key!(key)
      attribute!(key, value, &block)
    end

    # @api public
    # Same as {#attribute}, but will not raise an error on duplicate keys.
    #
    # @see #attribute
    # @param (see #attribute)
    # @yield (see #attribute)
    # @yieldparam (see #attribute)
    def attribute!(key, value = nil, &block)
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
    # @param key [#to_s]
    # @yield [builder]
    # @yieldparam builder [ArrayBuilder]
    def collection(key, &block)
      check_duplicate_key!(key)
      collection!(key, &block)
    end

    # @api public
    # Same as {#collection}, but will not raise an error on duplicate keys.
    #
    # @see #collection
    # @param (see #collection)
    # @yield (see #collection)
    # @yieldparam (see #collection)
    def collection!(key, &block)
      attribute!(key, ArrayBuilder.build(@context, &block))
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
    # @param key [#to_s]
    # @param list [#each]
    # @yield [builder, value] yields each value from list to build an array of hashes
    # @yieldparam builder [HashBuilder]
    # @yieldparam value
    def map(key, list, &block)
      check_duplicate_key!(key)
      map!(key, list, &block)
    end

    # @api public
    # Same as {#map}, but will not raise an error on duplicate keys.
    #
    # @see #map
    # @param (see #map)
    # @yield (see #map)
    # @yieldparam (see #map)
    def map!(key, list, &block)
      collection!(key) do |builder|
        list.each do |item|
          builder.element do |element|
            element.exec(item, &block)
          end
        end
      end
    end

    private

    # @param key [#to_s]
    # @raise [DuplicateKeyError] if key is defined
    # @return [nil]
    def check_duplicate_key!(key)
      if @data.has_key?(key.to_s)
        raise DuplicateKeyError, "'#{key}' is already defined"
      end
    end
  end
end
