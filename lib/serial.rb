require "serial/version"

module Serial
  class Serializer
    def initialize(&block)
      @block = block
    end

    def map(list)
      list.map { |item| call(item) }
    end

    def call(builder = HashBuilder.new, value)
      @block.call(builder, value)
      builder.to_h
    end

    def to_proc
      method(:call).to_proc
    end
  end

  class HashBuilder
    def self.build(&block)
      new(&block).to_h
    end

    def initialize(&block)
      @data = {}
      yield(self) if block_given?
    end

    def to_h
      @data
    end

    def as_json(*)
      @data
    end

    def attribute(key, value = nil)
      @data[key.to_s] = if block_given?
        HashBuilder.build do |builder|
          yield(builder, value)
        end
      else
        value
      end
    end

    def collection(key)
      attribute(key, ArrayBuilder.build { |builder| yield(builder) })
    end

    def map(key, list)
      collection(key) do |h|
        list.each do |item|
          h.element { |h| yield(h, item) }
        end
      end
    end
  end

  class ArrayBuilder
    def self.build(&block)
      new(&block).to_a
    end

    def initialize
      @data = []
      yield(self) if block_given?
    end

    def to_a
      @data
    end

    def as_json(*)
      @data
    end

    def element
      @data << HashBuilder.build do |builder|
        yield(builder)
      end
    end

    def collection(key)
      @data << ArrayBuilder.build do |builder|
        yield(builder)
      end
    end
  end
end
