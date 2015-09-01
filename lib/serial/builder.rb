module Serial
  class Builder
    def exec(*args, &block)
      if @context
        @context.instance_exec(self, *args, &block)
      else
        block.call(self, *args)
      end
    end

    def build(builder_klass, *args, &block)
      builder_klass.build(@context) do |builder|
        builder.exec(*args, &block)
      end
    end
  end
end
