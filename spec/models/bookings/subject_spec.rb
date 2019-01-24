require 'rails_helper'

RSpec.describe Bookings::Subject, type: :model do
  describe "Validation" do
    context "Name" do
      it { is_expected.to validate_presence_of(:name) }
    end
  end
end
