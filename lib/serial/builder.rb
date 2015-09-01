module Serial
  # @api private
  class Builder
    def self.build(context, *args, &block)
      builder = new(context)
      builder.exec(*args, &block)
      builder.data
    end

    attr_reader :data

    def exec(*args, &block)
      if @context
        @context.instance_exec(self, *args, &block)
      else
        block.call(self, *args)
      end
    end
  end
end
