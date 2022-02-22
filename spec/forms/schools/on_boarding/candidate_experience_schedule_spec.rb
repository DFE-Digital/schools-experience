require 'rails_helper'

describe Schools::OnBoarding::CandidateExperienceSchedule, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :start_time }
    it { is_expected.to respond_to :end_time }
    it { is_expected.to respond_to :times_flexible }
    it { is_expected.to respond_to :times_flexible_details }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :start_time }
    it { is_expected.to validate_presence_of :end_time }
    it { is_expected.not_to allow_value(nil).for :times_flexible }

    context 'start and end times' do
      valid_times = ['3', '19', '8AM', '8.15', '8:30AM', '8:30 AM', '8am', '8.00am', '3pm', '3 pm', '17:00']
      invalid_times = [
        '8A', '9;00am', 'nine forty in the morning', 'mid-morning', -2
      ]

      context 'valid times' do
        valid_times.each do |vt|
          specify "should allow #{vt} to be assigned to both start_time, end_time" do
            is_expected.to allow_value(vt).for(:start_time)
            is_expected.to allow_value(vt).for(:end_time)
          end
        end
      end

      context 'invalid times' do
        invalid_times.each do |ivt|
          specify "should not allow #{ivt} to be assigned to both start_time, end_time" do
            is_expected.not_to allow_value(ivt).for(:start_time)
            is_expected.not_to allow_value(ivt).for(:end_time)
          end
        end
      end
    end

    context 'times_flexible_details' do
      context 'when times_flexible' do
        subject { described_class.new times_flexible: true }

        it { is_expected.to validate_presence_of :times_flexible_details }
      end

      context 'when not times_flexible' do
        subject { described_class.new times_flexible: false }

        it { is_expected.not_to validate_presence_of :times_flexible_details }
      end
    end
  end
end
