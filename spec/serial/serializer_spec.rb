class FakeContext
  def dr_prefix(name)
    "Dr. #{name}"
  end
end

describe Serial::Serializer do
  def dr_prefix(name)
    "Doctor #{name}"
  end

  let(:person_with_friend) do
    double(name: "Kim", friend: double(name: "Jonas", friend: nil))
  end

  let(:other_person_with_friend) do
    double(name: "Piff", friend: double(name: "Puff", friend: nil))
  end

  let(:friend_serializer) do
    Serial::Serializer.new do |h, person|
      h.attribute(:name, dr_prefix(person.name))
      h.attribute(:friend, person.friend) do |h, friend|
        h.attribute(:name, dr_prefix(friend.name))
      end
    end
  end

  describe "#initialize" do
    it "raises an error if block is not provided" do
      expect { Serial::Serializer.new }.to raise_error(ArgumentError, /block/)
    end
  end

  describe "#call" do
    specify "without context the serializer is executed inside the context" do
      expect(friend_serializer.call(person_with_friend)).to eq({
        "name" => "Doctor Kim",
        "friend" => { "name" => "Doctor Jonas" }
      })
    end

    specify "with context the serializer is executed inside the context" do
      expect(friend_serializer.call(FakeContext.new, person_with_friend)).to eq({
        "name" => "Dr. Kim",
        "friend" => { "name" => "Dr. Jonas" }
      })
    end
  end

  describe "#map" do
    let(:people) { [person_with_friend, other_person_with_friend] }

    specify "without context the serializer is executed using normal closure rules" do
      expect(friend_serializer.map(people)).to eq([
        {
          "name" => "Doctor Kim",
          "friend" => { "name" => "Doctor Jonas" }
        },
        {
          "name" => "Doctor Piff",
          "friend" => { "name" => "Doctor Puff" }
        },
      ])
    end

    specify "with context the serializer is executed inside the context" do
      expect(friend_serializer.map(FakeContext.new, people)).to eq([
        {
          "name" => "Dr. Kim",
          "friend" => { "name" => "Dr. Jonas" }
        },
        {
          "name" => "Dr. Piff",
          "friend" => { "name" => "Dr. Puff" }
        },
      ])
    end
  end

  describe "#to_proc" do
    let(:evil) do
      double(title: "Evil", minion: person_with_friend)
    end

    let(:composed_serializer) do
      other_serializer = friend_serializer # => for context-test we require local variable.
      Serial::Serializer.new do |h, master|
        h.attribute(:title, dr_prefix(master.title))
        h.attribute(:minion, master.minion, &other_serializer)
      end
    end

    it "allows serializer composition" do
      expect(composed_serializer.call(evil)).to eq({
        "title" => "Doctor Evil",
        "minion" => {
          "name" => "Doctor Kim",
          "friend" => { "name" => "Doctor Jonas" }
        }
      })
    end

    specify "with context the serializer is executed inside the context" do
      expect(composed_serializer.call(FakeContext.new, evil)).to eq({
        "title" => "Dr. Evil",
        "minion" => {
          "name" => "Dr. Kim",
          "friend" => { "name" => "Dr. Jonas" }
        }
      })
    end
  end
end
