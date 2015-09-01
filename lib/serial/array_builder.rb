module Serial
  # @api private
  class ArrayBuilder < Builder
    def initialize(context)
      @context = context
      @data = []
    end

    def element(&block)
      @data << HashBuilder.build(@context, &block)
    end

    def collection(key, &block)
      @data << ArrayBuilder.build(@context, &block)
    end
  end
end
