module Serial
  class ArrayBuilder < Builder
    # @api private
    def initialize(context)
      @context = context
      @data = []
    end

    # @api public
    def element(&block)
      @data << HashBuilder.build(@context, &block)
    end

    # @api public
    def collection(&block)
      @data << ArrayBuilder.build(@context, &block)
    end
  end
end
