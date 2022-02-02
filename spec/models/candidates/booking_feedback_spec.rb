require "rails_helper"

describe Candidates::BookingFeedback, type: :model do
  it do
    is_expected.to belong_to(:booking)
      .class_name("Bookings::Booking")
      .with_foreign_key("bookings_booking_id")
  end

  it do
    is_expected.to define_enum_for(:effect_on_decision)
      .with_values(%i[negatively positively unaffected])
  end

  describe "validations" do
    %i[
      gave_realistic_impression
      covered_subject_of_interest
      influenced_decision
      intends_to_apply
    ].each do |attribute|
      it { is_expected.to allow_values(true, false).for(attribute) }
      it { is_expected.not_to allow_value(nil).for(attribute) }
    end

    it { is_expected.to validate_presence_of(:effect_on_decision) }

    it do
      subject.booking = create(:bookings_booking)
      is_expected.to validate_uniqueness_of(:bookings_booking_id)
    end
  end
end
