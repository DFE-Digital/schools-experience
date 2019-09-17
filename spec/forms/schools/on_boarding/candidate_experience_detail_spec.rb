require 'rails_helper'

describe Schools::OnBoarding::CandidateExperienceDetail, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :business_dress }
    it { is_expected.to respond_to :remove_piercings }
    it { is_expected.to respond_to :cover_up_tattoos }
    it { is_expected.to respond_to :remove_piercings }
    it { is_expected.to respond_to :smart_casual }
    it { is_expected.to respond_to :other_dress_requirements }
    it { is_expected.to respond_to :other_dress_requirements_detail }
    it { is_expected.to respond_to :parking_provided }
    it { is_expected.to respond_to :parking_details }
    it { is_expected.to respond_to :nearby_parking_details }
    it { is_expected.to respond_to :disabled_facilities }
    it { is_expected.to respond_to :disabled_facilities_details }
    it { is_expected.to respond_to :start_time }
    it { is_expected.to respond_to :end_time }
    it { is_expected.to respond_to :times_flexible }
    it { is_expected.to respond_to :times_flexible_details }
  end

  context 'validations' do
    it { is_expected.not_to allow_value(nil).for :business_dress }
    it { is_expected.not_to allow_value(nil).for :cover_up_tattoos }
    it { is_expected.not_to allow_value(nil).for :remove_piercings }
    it { is_expected.not_to allow_value(nil).for :smart_casual }
    it { is_expected.not_to allow_value(nil).for :other_dress_requirements }
    it { is_expected.not_to allow_value(nil).for :parking_provided }
    unless Feature.instance.active? :access_needs_journey
      it { is_expected.not_to allow_value(nil).for :disabled_facilities }
    end
    it { is_expected.to validate_presence_of :start_time }
    it { is_expected.to validate_presence_of :end_time }
    it { is_expected.not_to allow_value(nil).for :times_flexible }

    context 'when other is not selected' do
      subject { described_class.new other_dress_requirements: false }
      it { is_expected.not_to validate_presence_of :other_dress_requirements_detail }
    end

    context 'when other is selected' do
      subject { described_class.new other_dress_requirements: true }
      it { is_expected.to validate_presence_of :other_dress_requirements_detail }
    end

    context 'when parking_provided' do
      subject { described_class.new parking_provided: true }
      it { is_expected.to validate_presence_of :parking_details }
      it { is_expected.not_to validate_presence_of :nearby_parking_details }
    end

    context 'when not parking_provided' do
      subject { described_class.new parking_provided: false }
      it { is_expected.not_to validate_presence_of :parking_details }
      it { is_expected.to validate_presence_of :nearby_parking_details }
    end

    context 'when disabled_facilities' do
      unless Feature.instance.active? :access_needs_journey
        subject { described_class.new disabled_facilities: true }
        it { is_expected.to validate_presence_of :disabled_facilities_details }
      end
    end

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
