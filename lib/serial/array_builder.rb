module Serial
  # @api private
  class ArrayBuilder < Builder
    def initialize(context, &block)
      @context = context
      @data = []
      yield self
    end

    def element(&block)
      @data << build(HashBuilder, &block)
    end

    def collection(key, &block)
      @data << build(ArrayBuilder, &block)
    end
  end
end
