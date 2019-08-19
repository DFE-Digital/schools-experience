require 'rails_helper'

RSpec.describe Candidates::SchoolPresenter do
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
        build :bookings_profile, dbs_requires_check: nil, dbs_policy_details: nil
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

      context 'when true' do
        before { profile.dbs_requires_check = true }

        it { is_expected.to eql 'Yes' }
      end

      context 'when false' do
        before { profile.dbs_requires_check = false }

        it { is_expected.to eql 'No - Candidates will be accompanied at all times' }
      end
    end
  end

  describe '#dbs_policy' do
    context 'when legacy profile' do
      let :legacy_profile do
        build :bookings_profile,
          dbs_requires_check: nil,
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
end
