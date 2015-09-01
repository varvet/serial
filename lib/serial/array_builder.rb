module Serial
  class ArrayBuilder < Builder
    def self.build(context, &block)
      new(context, &block).to_a
    end

    def initialize(context, &block)
      @context = context
      @data = []
      yield self
    end

    def to_a
      @data
    end

    def as_json(*)
      @data
    end

    def element(&block)
      @data << build(HashBuilder, &block)
    end

    def collection(key, &block)
      @data << build(ArrayBuilder, &block)
    end
  end
end
