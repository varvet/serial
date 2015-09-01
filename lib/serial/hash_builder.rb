module Serial
  # @api private
  class HashBuilder < Builder
    def initialize(context, &block)
      @context = context
      @data = {}
      yield self
    end

    def attribute(key, value = nil, &block)
      value = build(HashBuilder, value, &block) if block
      @data[key.to_s] = value
    end

    def collection(key, &block)
      list = build(ArrayBuilder, &block)
      attribute(key, list)
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
