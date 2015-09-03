module Serial
  class Serializer
    def initialize(&block)
      @block = block
    end

    def map(context = nil, list)
      list.map { |item| call(context, item) }
    end

    def call(context = nil, value)
      HashBuilder.build(context, value, &@block)
    end

    def to_proc
      block = @block
      proc do |builder, *args|
        builder.exec(*args, &block)
      end
    end
  end
end
