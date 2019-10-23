require 'rails_helper'

describe Schools::PlacementRequests::ConfirmBooking, type: :model do
  attributes = %i(placement_details bookings_subject_id).freeze

  describe 'Attributes' do
    attributes.each do |attribute_name|
      let(:attribute_name) { attribute_name }
      specify "should have attribute #{attribute_name}" do
        expect(subject).to respond_to(attribute_name)
      end
    end
  end

  describe 'Validation' do
    attributes.each do |attribute_name|
      let(:attribute_name) { attribute_name }
      specify "should have attribute #{attribute_name}" do
        expect(subject).to validate_presence_of(attribute_name)
      end
    end

    context '#date' do
      let(:past_dates) { [1.week.ago, 1.day.ago, Date.yesterday] }
      let(:future_dates) { [Date.today, 1.day.from_now, 1.week.from_now, 1.year.from_now] }
      let!(:bookings_subject) { create(:bookings_subject) }

      specify 'should not allow past dates' do
        past_dates.each do |pd|
          expect(
            described_class.new(
              bookings_subject_id: bookings_subject.id,
              placement_details: 'yes',
              date: pd
            )
          ).not_to be_valid
        end
      end

      specify 'should allow future dates' do
        future_dates.each do |fd|
          expect(subject).to allow_value(fd).for(:date)
        end
      end
    end
  end
end
