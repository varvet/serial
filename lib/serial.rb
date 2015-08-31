require "serial/version"

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
        instance_exec(builder, value, &block)
      end
    end

    def to_proc
      block = @block
      proc { |builder, value| instance_exec(builder, value, &block) }
    end
  end

  class HashBuilder
    def self.build(context, &block)
      new(context, &block).to_h
    end

    def initialize(context, &block)
      @context = context
      @data = {}
      @context.instance_exec(self, &block)
    end

    def to_h
      @data
    end

    def as_json(*)
      @data
    end

    def attribute(key, value = nil, &block)
      @data[key.to_s] = if block
        HashBuilder.build(@context) do |builder|
          instance_exec(builder, value, &block)
        end
      else
        value
      end
    end

    def collection(key, &block)
      list = ArrayBuilder.build(@context) do |builder|
        instance_exec(builder, &block)
      end
      attribute(key, list)
    end

    def map(key, list, &block)
      collection(key) do |h|
        list.each do |item|
          h.element { |h| instance_exec(h, item, &block) }
        end
      end
    end
  end

  class ArrayBuilder
    def self.build(context, &block)
      new(context, &block).to_a
    end

    def initialize(context, &block)
      @context = context
      @data = []
      @context.instance_exec(self, &block)
    end

    def to_a
      @data
    end

    def as_json(*)
      @data
    end

    def element(&block)
      @data << HashBuilder.build(@context) do |builder|
        instance_exec(builder, &block)
      end
    end

    def collection(key, &block)
      @data << ArrayBuilder.build(@context) do |builder|
        instance_exec(builder, &block)
      end
    end
  end
end
