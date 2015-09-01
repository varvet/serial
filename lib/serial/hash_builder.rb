module Serial
  class HashBuilder < Builder
    def self.build(context, &block)
      new(context, &block).to_h
    end

    def initialize(context, &block)
      @context = context
      @data = {}
      yield self
    end

    def to_h
      @data
    end

    def as_json(*)
      @data
    end

    def attribute(key, value = nil, &block)
      @data[key.to_s] = if block
        build(HashBuilder, value, &block)
      else
        value
      end
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
