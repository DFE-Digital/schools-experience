require 'rails_helper'

RSpec.describe Candidates::SchoolPresenter do
  include ActiveSupport::Testing::TimeHelpers

  let(:profile) { build(:bookings_profile) }
  let(:school) { profile.school }
  subject { described_class.new(school, profile) }

  describe ".school" do
    it { expect(subject.school).to eql(school) }
  end

  describe ".profile" do
    it { expect(subject.profile).to eql(profile) }
  end

  describe "attributes delegated to the school" do
    it { expect(subject.name).to eql(school.name) }
    it { expect(subject.urn).to eql(school.urn) }
    it { expect(subject.coordinates).to eql(school.coordinates) }
    it { expect(subject.website).to eql(school.website) }

    it do
      expect(subject.availability_preference_fixed?).to \
        eql(school.availability_preference_fixed?)
    end
  end

  describe "attributes delegated to the profile" do
    it { expect(subject.experience_details).to eql(profile.experience_details) }
    it { expect(subject.individual_requirements).to eql(profile.individual_requirements) }
    it { expect(subject.description_details).to eql(profile.description_details) }
    it { expect(subject.disabled_facilities).to eql(profile.disabled_facilities) }
    it { expect(subject.teacher_training_info).to eql(profile.teacher_training_info) }
    it { expect(subject.teacher_training_url).to eql(profile.teacher_training_url) }
    it { expect(subject.parking_provided).to eql(profile.parking_provided) }
    it { expect(subject.parking_details).to eql(profile.parking_details) }
    it { expect(subject.start_time).to eql(profile.start_time) }
    it { expect(subject.end_time).to eql(profile.end_time) }
    it { expect(subject.flexible_on_times).to eql(profile.flexible_on_times) }
    it { expect(subject.dress_code_other_details).to eql(profile.dress_code_other_details) }
    it { expect(subject.has_fees?).to eql(profile.has_fees?) }
  end

  describe '#dress_code' do
    before do
      profile.dress_code_business = true
      profile.dress_code_cover_tattoos = true
    end

    it 'shows the contatenated dress code booleans' do
      expect(subject.dress_code).to eql("Business dress, Cover up tattoos")
    end
  end

  describe '#dress_code?' do
    subject { described_class.new(school, profile).dress_code? }

    context 'with booleans' do
      before { profile.dress_code_business = true }
      it { is_expected.to be true }
    end

    context 'with details' do
      before { profile.dress_code_other_details = "lorem ipsum" }
      it { is_expected.to be true }
    end

    context 'with both' do
      before do
        profile.dress_code_business = true
        profile.dress_code_other_details = 'lorem ipsum'
      end

      it { is_expected.to be true }
    end

    context 'with neither' do
      it { is_expected.to be false }
    end
  end

  describe '#formatted_dress_code' do
    subject { described_class.new(school, profile).formatted_dress_code }

    context 'with content' do
      before { profile.dress_code_other_details = 'lorem ipsum' }
      it { is_expected.to match(/<p>lorem ipsum<\/p>/) }
    end

    context 'without content' do
      it { is_expected.to be_blank }
    end
  end

  describe '#dbs_required' do
    context 'when legacy profile' do
      let :legacy_profile do
        build :bookings_profile, dbs_policy_conditions: nil, dbs_policy_details: nil
      end

      subject { described_class.new(school, legacy_profile).dbs_required }

      context 'when yes' do
        before { legacy_profile.dbs_required = 'always' }
        it { is_expected.to eql "Yes - Always" }
      end

      context 'when no' do
        before { legacy_profile.dbs_required = 'never' }
        it { is_expected.to eql "No - Candidates will be accompanied at all times" }
      end

      context 'when yes' do
        before { legacy_profile.dbs_required = 'sometimes' }
        it { is_expected.to eql "Yes - Sometimes" }
      end
    end

    context 'when new profile' do
      subject { described_class.new(school, profile).dbs_required }

      context 'when required' do
        before { profile.dbs_policy_conditions = "required" }

        it { is_expected.to eql 'Yes' }
      end

      context 'when inschool' do
        before { profile.dbs_policy_conditions = "inschool" }

        it { is_expected.to eql 'Yes - when in school' }
      end

      context 'when notrequired' do
        before { profile.dbs_policy_conditions = "notrequired" }

        it { is_expected.to eql 'No - Candidates will be accompanied at all times when in school' }
      end
    end
  end

  describe '#dbs_policy' do
    context 'when legacy profile' do
      let :legacy_profile do
        build :bookings_profile,
          dbs_policy_conditions: nil,
          dbs_policy_details: nil,
          dbs_policy: 'Our DBS policy'
      end

      subject { described_class.new(school, legacy_profile).dbs_policy }

      it { is_expected.to eql 'Our DBS policy' }
    end

    context 'when new profile' do
      subject { described_class.new(school, profile).dbs_policy }

      it { is_expected.to eql 'Must have recent dbs check' }
    end
  end

  describe "available date methods" do
    let(:instance) { described_class.new(school, profile) }
    let(:placement_date_defaults) { { bookings_school: school } }

    let(:early_date) { 1.week.from_now.to_date }
    let(:late_date) { 1.month.from_now.to_date }

    let(:inactive_date) { create :bookings_placement_date, :inactive, :not_supporting_subjects, **placement_date_defaults }
    let(:past_date) { create :bookings_placement_date, :in_the_past, :not_supporting_subjects, **placement_date_defaults }
    let(:outside_availability_window) { create :bookings_placement_date, date: Date.new(2021, 6, 25), **placement_date_defaults }

    let(:primary_early_date) { create :bookings_placement_date, :not_supporting_subjects, date: Date.new(2021, 4, 1), **placement_date_defaults }
    let(:primary_late_date) { create :bookings_placement_date, :not_supporting_subjects, date: Date.new(2021, 5, 16), **placement_date_defaults }
    let(:secondary_early_date) { create :bookings_placement_date, date: Date.new(2021, 4, 5), **placement_date_defaults }
    let(:secondary_late_date) { create :bookings_placement_date, date: Date.new(2021, 5, 4), **placement_date_defaults }

    let(:unavailable_dates) do
      [inactive_date, past_date, outside_availability_window]
    end
    let(:available_dates) do
      [secondary_early_date, secondary_late_date, primary_early_date, primary_late_date]
    end

    around do |example|
      travel_to(Date.new(2021, 3, 30)) { example.run }
    end

    before do
      school.save!
      school.bookings_placement_dates += unavailable_dates
      school.bookings_placement_dates += available_dates
    end

    describe "#total_available_dates" do
      subject { instance.total_available_dates }

      it { is_expected.to eq(available_dates.count) }
    end

    describe "#available_dates_by_month" do
      subject(:hash) { instance.available_dates_by_month }

      it { expect(hash.keys).to eq([Date.new(2021, 4, 1), Date.new(2021, 5, 1)]) }
      it { expect(hash[Date.new(2021, 4, 1)]).to eq([primary_early_date, secondary_early_date]) }
      it { expect(hash[Date.new(2021, 5, 1)]).to eq([secondary_late_date, primary_late_date]) }
    end
  end
end
