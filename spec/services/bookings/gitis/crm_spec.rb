require 'rails_helper'

describe Bookings::Gitis::CRM, type: :model do
  describe '.initialize' do
    it "will succeed with access token" do
      expect(Bookings::Gitis::CRM.new('something')).to \
        be_instance_of(Bookings::Gitis::CRM)
    end

    it "will raise an exception without an access token" do
      expect {
        Bookings::Gitis::CRM.new
      }.to raise_exception(ArgumentError)
    end
  end

  describe '.find' do
    let(:gitis) { Bookings::Gitis::CRM.new('something') }

    context 'with no account_ids' do
      it "will raise an exception" do
        expect {
          gitis.find
        }.to raise_exception(ArgumentError)
      end
    end

    context 'with single account_ids' do
      before { @contacts = gitis.find(1) }

      it "will return a single account" do
        expect(@contacts).to be_instance_of Bookings::Gitis::Contact
      end
    end

    context 'with multiple account_ids' do
      before { @contacts = gitis.find(1, 2, 3) }

      it "will return an account per id" do
        expect(@contacts.length).to eq(3)
        expect(@contacts).to all be_instance_of(Bookings::Gitis::Contact)
      end
    end

    context 'with array of account_ids' do
      before { @contacts = gitis.find([1, 2, 3]) }

      it "will return an account per id" do
        expect(@contacts.length).to eq(3)
        expect(@contacts).to all be_instance_of(Bookings::Gitis::Contact)
      end
    end
  end
end
