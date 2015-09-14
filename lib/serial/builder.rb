module Serial
  # @api private
  #
  # Builder contains common methods to the serializer DSL.
  class Builder
    # Create the builder, execute the block inside it, and return its' data.
    # Any superflous arguments are given to {#exec}.
    #
    # @param context [#instance_exec, nil] the context to execute block inside
    # @yield (see #exec)
    # @yieldparam (see #exec)
    # @return [#data]
    def self.build(context, *args, &block)
      builder = new(context)
      builder.exec(*args, &block)
      builder.data
    end

    # Builder data, depends on what kind of builder it is.
    #
    # @return [Array, Hash]
    attr_reader :data

    # Executes a block in the configured context, if there is one, otherwise using regular closure scoping.
    #
    #
    # @yield [self, *args]
    # @yieldparam self [Builder] passes in self as the first parameter.
    # @yieldparam *args superflous arguments are passed to the block.
    def exec(*args, &block)
      if @context
        @context.instance_exec(self, *args, &block)
      else
        block.call(self, *args)
      end
    end
  end
end
