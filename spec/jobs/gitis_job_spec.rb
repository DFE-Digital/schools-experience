require 'rails_helper'

describe GitisJob do
  describe '#gitis' do
    subject { described_class.new.send(:gitis) }
    it do
      is_expected.to have_attributes \
        fake_store: kind_of(Bookings::Gitis::Store::Fake)
    end
  end
end
