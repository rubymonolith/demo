require "rails_helper"

RSpec.describe Superform::Namespace do
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
    Superform::Namespace.new(:user, object: user)
  end

  describe "root" do
    subject { form }
    it "has key" do
      expect(form.key).to eql(:user)
    end
    context "DOM" do
      let(:dom) { Superform::DOM.new(form) }
      it "has name" do
        expect(dom.name).to eql("user")
      end
      it "has id" do
        expect(dom.id).to eql("user")
      end
      it "has title" do
        expect(dom.title).to eql("User")
      end
    end
  end

  describe "child" do
    let(:field) { form.field(:name) }
    subject { field }
    it "returns value from parent" do
      expect(subject.value).to eql "Brad"
    end
    context "DOM" do
      let(:dom) { Superform::DOM.new(field) }

      it "has name" do
        expect(dom.name).to eql("user[name]")
      end
      it "has id" do
        expect(dom.id).to eql("user_name")
      end
      it "has key" do
        expect(dom.key).to eql("name")
      end
      it "has title" do
        expect(dom.title).to eql("Name")
      end
    end
  end

  describe "#field" do
    let(:field) { form.namespace(:one).namespace(:two).namespace(:three).field(:four, value: 5) }
    subject{ field }
    it "returns value" do
      expect(subject.value).to eql 5
    end
    context "DOM" do
      let(:dom) { Superform::DOM.new(field) }

      it "has name" do
        expect(dom.name).to eql("user[one][two][three][four]")
      end
      it "has id" do
        expect(dom.id).to eql("user_one_two_three_four")
      end
      it "has key" do
        expect(dom.key).to eql("four")
      end
      it "has title" do
        expect(dom.title).to eql("Four")
      end
    end
  end

  describe "#values" do
    context "array of values" do
      let(:field) { form.collection(:nicknames).first }
      subject { field }
      it "returns value" do
        expect(subject.value).to eql "Dude"
      end
      it "returns key" do
        expect(subject.key).to eql 0
      end
      context "DOM" do
        let(:dom) { Superform::DOM.new(field) }

        it "has name" do
          expect(dom.name).to eql("user[nicknames][]")
        end
        it "has id" do
          expect(dom.id).to eql("user_nicknames_0")
        end
        it "has key" do
          expect(dom.key).to eql("0")
        end
        it "has title" do
          expect(dom.title).to eql("0")
        end
      end
    end

    context "array of objects" do
      let(:field) { form.collection(:addresses).first.field(:street) }
      subject { field }
      it "returns value" do
        expect(subject.value).to eql("Main St")
      end
      it "returns key" do
        expect(subject.key).to eql(:street)
      end
      context "DOM" do
        let(:dom) { Superform::DOM.new(field) }

        it "has name" do
          expect(dom.name).to eql("user[addresses][][street]")
        end
        it "has id" do
          expect(dom.id).to eql("user_addresses_0_street")
        end
        it "has key" do
          expect(dom.key).to eql("street")
        end
        it "has title" do
          expect(dom.title).to eql("Street")
        end
      end
    end
  end

  describe "mapping" do
    subject { form.to_h }

    before do
      form.namespace(:name) do |name|
        name.field(:first, value: "Brad")
        name.field(:last)
      end
      form.field(:email)
      form.collection(:nicknames)
      form.collection(:addresses) do |address|
        address.field(:id, permit: false)
        address.field(:street)
      end
      form.collection(:modulo, object: 4.times) do |modulo|
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
          nicknames: ["Dude", "The Dude"],
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
          nicknames: nil,
          addresses: [
            {
              id: 999,
              street: "Lame Street",
              extra_garbage: "Super garbage"
            },
            {
              id: 888,
              street: "Bigsby Lane",
              malicious_garbage: "I will steal your address!"
            },
            {
              id: 777,
              street: "Amazing Avenue",
              lots_of_trash: "I will steal your address!"
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
            { id: 200, street: "Bigsby Lane" },
            { id: 777, street: "Amazing Avenue" }
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
