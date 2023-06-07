require "rails_helper"

RSpec.describe Phlex::Phorm::Field do
  User = Data.define(:name, :email, :nicknames, :addresses)
  Address = Data.define(:id, :street, :city)

  let(:user) do
    User.new(
      name: "Brad",
      email: "brad@example.com",
      nicknames: ["Dude", "The Dude"],
      addresses: [
        Address.new(id: 100, street: "Main St", city: "Small Town"),
        Address.new(id: 200, street: "Big Blvd", city: "Metropolis")
      ]
    )
  end

  let(:form) do
    Phlex::Phorm::Field.new(:user, value: user)
  end

  describe "root" do
    subject { form }
    it "has name" do
      expect(form.name).to eql(:user)
    end
    it "has value" do
      expect(form.value).to eql(user)
    end
  end

  describe "child" do
    let(:field) { form.field(:name) }
    subject { field }
    it "returns value from parent" do
      expect(subject.value).to eql "Brad"
    end
    describe "#dom" do
      subject { field.dom }
      it "generates name" do
        expect(subject.name).to eql("user[name]")
      end
      it "generates id" do
        expect(subject.id).to eql("user_name")
      end
    end
  end

  describe "#field" do
    let(:field) { form.field(:one).field(:two).field(:three).field(:four, value: 5) }
    subject{ field }
    it "returns value" do
      expect(subject.value).to eql 5
    end
    describe "#dom" do
      subject{ field.dom }
      it "returns name_keys" do
        expect(subject.name_keys.map(&:name)).to eql %w[user one two three four]
      end
      it "returns id_keys" do
        expect(subject.id_keys.map(&:name)).to eql %w[user one two three four]
      end
      it "generates name" do
        expect(subject.name).to eql("user[one][two][three][four]")
      end
      it "generates id" do
        expect(subject.id).to eql("user_one_two_three_four")
      end
    end
  end

  describe "#values" do
    context "array of values" do
      let(:field) { form.collection(:nicknames).values.first }
      subject { field }
      it "returns value" do
        expect(subject.value).to eql "Dude"
      end
      it "returns name" do
        expect(subject.name).to be_nil
      end
      describe "#dom" do
        subject { field.dom }
        it "returns name_keys" do
          expect(subject.name_keys).to eql [:user, :nicknames, nil]
        end
        it "returns id_keys" do
          expect(subject.id_keys).to eql [:user, :nicknames, 0]
        end
        it "generates name" do
          expect(subject.name).to eql("user[nicknames][]")
        end
        it "generates id" do
          expect(subject.id).to eql("user_nicknames_0")
        end
      end
    end

    context "array of objects" do
      let(:field) { form.collection(:addresses).values.first.field(:street) }
      subject { field }
      it "returns value" do
        expect(subject.value).to eql("Main St")
      end
      it "returns name" do
        expect(subject.name).to eql(:street)
      end
      describe "#dom" do
        subject { field.dom }
        it "returns name_keys" do
          expect(subject.name_keys).to eql [:user, :addresses, nil, :street]
        end
        it "returns id_keys" do
          expect(subject.id_keys).to eql [:user, :addresses, 0, :street]
        end
        it "generates name" do
          expect(subject.name).to eql("user[addresses][][street]")
        end
        it "generates id" do
          expect(subject.id).to eql("user_addresses_0_street")
        end
      end
    end
  end

  describe "mapping" do
    subject { form.to_h }

    before do
      form.field(:name) do |name|
        name.field(:first, value: "Brad")
        name.field(:last)
      end
      form.field(:email)
      form.collection(:nicknames)
      form.collection(:addresses).each do |address|
        address.field(:id, permitted: false)
        address.field(:street)
      end
      form.collection(:modulo, value: 4.times).each do |modulo|
        if (modulo.value % 2 == 0)
          modulo.field(:fizz, value: modulo.value)
        else
          modulo.field(:buzz) do |buzz|
            buzz.field(:saw, value: modulo.value)
          end
        end
      end
    end

    describe "#to_h" do
      it do
        is_expected.to eql(
          name: { first: "Brad", last: "d" },
          nicknames: user.nicknames,
          email: "brad@example.com",
          addresses: [
            { id: 100, street: "Main St" },
            { id: 200, street: "Big Blvd" }
          ],
          modulo: [
            { fizz: 0 },
            { buzz: { saw: 1 }},
            { fizz: 2 },
            { buzz: { saw: 3 }}
          ]
        )
      end
    end

    describe "#assign" do
      let(:params) do
        {
          email: "bard@example.com",
          malicious_garbage: "haha! You will never win my pretty!",
          addresses: [
            {
              id: 999,
              street: "Lame Street"
            },
            {
              id: 888,
              street: "Bigsby Lane",
              malicious_garbage: "I will steal your address!"
            }
          ],
          modulo: [
            { fizz: 200, malicious_garbage: "I will foil your plans!" },
            { malicious_garbage: "The world will be mine!" }
          ]
        }
      end
      before { form.assign params }

      it "does not include fields not in list" do
        expect(subject.keys).to_not include :malicious_garbage
      end

      it "includes fields in list" do
        expect(form.to_h).to eql(
          name: { first: "Brad", last: "d" },
          nicknames: nil,
          email: "bard@example.com",
          addresses: [
            { id: 100, street: "Lame Street" },
            { id: 200, street: "Bigsby Lane" }
          ],
          modulo: [
            { fizz: 200 },
            { buzz: { saw: 1 }},
            { fizz: 2 },
            { buzz: { saw: 3 }}
          ]
        )
      end
    end
  end
end
