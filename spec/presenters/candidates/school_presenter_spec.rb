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

  describe '#primary_dates' do
    let(:placement_date_defaults) { { bookings_school: school } }
    let(:unavailable_date) { FactoryBot.create :bookings_placement_date, :inactive, :not_supporting_subjects, **placement_date_defaults }
    let(:available_date) { FactoryBot.create :bookings_placement_date, :not_supporting_subjects, **placement_date_defaults }
    let(:secondary_date) { FactoryBot.create :bookings_placement_date, **placement_date_defaults }
    let(:past_date) { FactoryBot.create :bookings_placement_date, :in_the_past, :not_supporting_subjects, **placement_date_defaults }

    before do
      school.save!
      school.bookings_placement_dates << unavailable_date
      school.bookings_placement_dates << available_date
      school.bookings_placement_dates << secondary_date
      school.bookings_placement_dates << past_date
    end

    subject { described_class.new(school, profile).primary_dates }

    specify "should include the available primary date" do
      expect(subject).to include(available_date)
    end

    specify "should not include the past and unavailable primary dates or secondary dates" do
      expect(subject).not_to include(unavailable_date, past_date, secondary_date)
    end
  end

  describe '#secondary_dates' do
    let(:placement_date_defaults) { { bookings_school: school } }
    let(:unavailable_date) { FactoryBot.create :bookings_placement_date, :inactive, **placement_date_defaults }
    let(:available_date) { FactoryBot.create :bookings_placement_date, **placement_date_defaults }
    let(:past_date) { FactoryBot.create :bookings_placement_date, :in_the_past, **placement_date_defaults }
    let(:primary_date) { FactoryBot.create :bookings_placement_date, :not_supporting_subjects, **placement_date_defaults }

    before do
      school.save!
      school.bookings_placement_dates << unavailable_date
      school.bookings_placement_dates << available_date
      school.bookings_placement_dates << primary_date
      school.bookings_placement_dates << past_date
    end

    subject { described_class.new(school, profile).secondary_dates }

    specify "should include the available secondary date" do
      expect(subject).to include(available_date)
    end

    specify "should not include the past and unavailable secondary dates or primary dates" do
      expect(subject).not_to include(unavailable_date, past_date, primary_date)
    end
  end

  describe '#secondary_dates_grouped_by_date' do
    let(:early_date) { 1.week.from_now.to_date }
    let(:late_date) { 1.month.from_now.to_date }
    let(:all_subjects) { Array.wrap('All subjects (1 day)') }

    let(:placement_date_early_with_maths) do
      build(:bookings_placement_date, date: early_date, subject_specific: true).tap do |pd|
        pd.subjects << Bookings::Subject.find_by(name: 'Maths')
        pd.subject_specific = true
        pd.save
      end
    end

    let(:placement_date_early) do
      create(:bookings_placement_date, date: early_date)
    end

    let(:placement_date_late) do
      create(:bookings_placement_date, date: late_date)
    end

    let(:placement_dates) do
      [placement_date_early, placement_date_late, placement_date_early_with_maths]
    end

    before do
      allow(subject).to receive(:secondary_dates).and_return(placement_dates)
    end

    specify 'should correctly itemise by date' do
      expect(subject.secondary_dates_grouped_by_date.keys).to match_array([early_date.to_date, late_date.to_date])
    end

    specify 'dates with subject specific and non-specific dates should list both' do
      expect(subject.secondary_dates_grouped_by_date[early_date].map(&:name_with_duration)).to match_array(all_subjects.concat(["Maths (1 day)"]))
    end

    specify "non-specific dates should be described as 'All subjects'" do
      expect(subject.secondary_dates_grouped_by_date[late_date].map(&:name_with_duration)).to match_array(all_subjects)
    end

    context 'sorting' do
      let(:date) { 1.day.from_now.to_date }

      let(:physics) { Bookings::Subject.find_by(name: 'Physics') }
      let(:maths) { Bookings::Subject.find_by(name: 'Maths') }
      let(:biology) { Bookings::Subject.find_by(name: 'Biology') }

      let(:pd_subjects) { [physics, maths, biology] }

      let(:placement_date_with_multiple_subjects) do
        build(:bookings_placement_date, date: date, subject_specific: true).tap do |pd|
          pd.subjects << pd_subjects
          pd.save
        end
      end

      before do
        allow(subject).to receive(:secondary_dates).and_return(Array.wrap(placement_date_with_multiple_subjects))
      end

      specify 'subjects should be sorted alphabetically' do
        expect(subject.secondary_dates_grouped_by_date[date].map(&:name_with_duration)).to eql(pd_subjects.map(&:name).map { |s| "#{s} (1 day)" }.sort)
      end
    end
  end
end
