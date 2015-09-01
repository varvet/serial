module Serial
  class Serializer
    def initialize(&block)
      @block = block
    end

    def map(list)
      list.map { |item| call(item) }
    end

    def call(context = nil, value)
      block = @block
      HashBuilder.build(context) do |builder|
        builder.exec(value, &block)
      end
    end

    def to_proc
      block = @block
      proc { |builder, value| builder.exec(value, &block) }
    end
  end
end
