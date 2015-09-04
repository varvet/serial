class FakeContext
  def dr_prefix(name)
    "Dr. #{name}"
  end
end

describe Serial do
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
    this_serializer = Serial::Serializer.new do |h, person|
      h.attribute(:name, dr_prefix(person.name))
      h.attribute(:friend, person.friend, &this_serializer) if person.friend
    end
  end

  it "has a version number" do
    expect(Serial::VERSION).not_to be nil
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

    specify "without context the serializer is executed inside the context" do
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
end
