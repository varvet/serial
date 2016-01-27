describe "Serial DSL" do
  def serialize(subject = nil, &block)
    Serial::Serializer.new(&block).call(nil, subject)
  end

  describe "HashBuilder" do
    let(:report_serializer) do
      Serial::Serializer.new do |h, subject|
        h.attribute(:name, subject)
      end
    end

    describe "#attribute" do
      it "serializes simple attributes" do
        data = serialize { |h| h.attribute(:hello, "World") }

        expect(data).to eq({ "hello" => "World" })
      end

      it "serializes nested attributes" do
        data = serialize do |h|
          h.attribute(:hi) { |h| h.attribute(:hello, "World") }
        end

        expect(data).to eq({ "hi" => { "hello" => "World" } })
      end

      it "forwards value when serializing simple attributes" do
        data = serialize("World") { |h, x| h.attribute(:hello, x) }

        expect(data).to eq({ "hello" => "World" })
      end

      it "forwards value when serializing nested attributes" do
        data = serialize do |h|
          h.attribute(:hi, "World") { |h, x| h.attribute(:hello, x) }
        end

        expect(data).to eq({ "hi" => { "hello" => "World" } })
      end

      it "explodes if the attribute already exists" do
        serializer = Serial::Serializer.new do |h|
          h.attribute(:hi, "a")
          h.attribute(:hi, "b")
        end

        expect { serializer.call(nil) }.to raise_error(Serial::DuplicateKeyError, "'hi' is already defined")
      end
    end

    describe "#map" do
      it "serializes a list of values" do
        data = serialize do |h|
          h.map(:numbers, ["a", "b", "c"]) do |h, x|
            h.attribute(:x, x)
            h.attribute(:X, x.upcase)
          end
        end

        expect(data).to eq({
          "numbers" => [
            { "x" => "a", "X" => "A" },
            { "x" => "b", "X" => "B" },
            { "x" => "c", "X" => "C" },
          ]
        })
      end

      it "explodes if the attribute already exists" do
        serializer = Serial::Serializer.new do |h|
          h.attribute(:hi, "a")
          h.map(:hi, [1]) do |h, id|
            h.attribute(:id, id)
          end
        end

        expect { serializer.call(nil) }.to raise_error(Serial::DuplicateKeyError, "'hi' is already defined")
      end
    end

    describe "#collection" do
      it "serializes a collection" do
        data = serialize do |h|
          h.collection(:numbers) do |l|
          end
        end

        expect(data).to eq({ "numbers" => [] })
      end

      it "explodes if the attribute already exists" do
        serializer = Serial::Serializer.new do |h|
          h.attribute(:hi, "a")
          h.collection(:hi) do |l|
            l.element do |h|
              h.attribute(:id, 1)
            end
          end
        end

        expect { serializer.call(nil) }.to raise_error(Serial::DuplicateKeyError, "'hi' is already defined")
      end
    end

    describe "#merge" do
      it "merges a serializer into the current scope" do
        data = serialize do |h|
          h.attribute(:extended, "Extended")
          h.merge("Hi", &report_serializer)
        end

        expect(data).to eq({ "name" => "Hi", "extended" => "Extended" })
      end

      it "explodes if a merged attribute already exists" do
        full_report_serializer = Serial::Serializer.new do |h|
          h.attribute(:name, "Replaced")
          h.attribute(:extended, "Extended")
          h.merge("Hi", &report_serializer)
        end

        expect { full_report_serializer.call(nil) }.to raise_error(Serial::DuplicateKeyError, "'name' is already defined")
      end
    end

    describe "!-methods" do
      describe "#attribute!" do
        it "does not explode if the attribute already exists" do
          serializer = Serial::Serializer.new do |h|
            h.attribute(:hi, "a")
            h.attribute!(:hi, "b")
          end

          expect(serializer.call(nil)).to eq({ "hi" => "b" })
        end
      end

      describe "#map!" do
        it "does not explode if the attribute already exists" do
          serializer = Serial::Serializer.new do |h|
            h.attribute(:hi, "a")
            h.map!(:hi, [1]) do |h, id|
              h.attribute(:id, id)
            end
          end

          expect(serializer.call(nil)).to eq({ "hi" => [{ "id" => 1 }] })
        end
      end

      describe "#collection!" do
        it "does not explode if the attribute already exists" do
          serializer = Serial::Serializer.new do |h|
            h.attribute(:hi, "a")
            h.collection!(:hi) do |l|
              l.element do |h|
                h.attribute(:id, 1)
              end
            end
          end

          expect(serializer.call(nil)).to eq({ "hi" => [{ "id" => 1 }] })
        end
      end

      describe "#merge!" do
        it "does not explode if a merged attribute already exists" do
          full_report_serializer = Serial::Serializer.new do |h|
            h.attribute(:name, "Replaced")
            h.attribute(:extended, "Extended")
            h.merge!("Hi", &report_serializer)
          end

          expect(full_report_serializer.call(nil)).to eq({ "name" => "Hi", "extended" => "Extended" })
        end
      end
    end
  end

  describe "ArrayBuilder" do
    def collection(&block)
      serialize { |h| h.collection(:collection, &block) }
    end

    describe "#element" do
      it "serializes a hash in a collection" do
        data = collection do |l|
          l.element { |h| h.attribute(:hello, "World") }
          l.element { |h| h.attribute(:hi, "There") }
        end

        expect(data).to eq({
          "collection" => [
            { "hello" => "World" },
            { "hi" => "There" }
          ]
        })
      end

      it "accepts a value" do
        data = collection do |l|
          l.element("hello")
          l.element("world")
        end

        expect(data).to eq({
          "collection" => ["hello", "world"]
        })
      end

      it "raises an error when both block and value given" do
        expect do
          collection do |l|
            l.element("hello") { |h| h.attribute(:foo, "bar") }
          end
        end.to raise_error(ArgumentError, "cannot pass both a block and an argument to `element`")
      end
    end

    describe "#collection" do
      it "serializes a collection inside of a collection" do
        data = collection do |l|
          l.collection do |l|
            l.element { |h| h.attribute(:hello, "World") }
            l.element { |h| h.attribute(:hi, "There") }
          end

          l.collection do |l|
            l.element { |h| h.attribute(:piff, "Puff") }
          end
        end

        expect(data).to eq({
          "collection" => [
            [{ "hello" => "World" }, { "hi" => "There" }],
            [{ "piff" => "Puff" }]
          ]
        })
      end
    end
  end
end
