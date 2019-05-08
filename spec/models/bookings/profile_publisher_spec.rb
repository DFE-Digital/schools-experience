require 'rails_helper'

RSpec.describe Bookings::ProfilePublisher, type: :model do
  describe "#new" do
    context "with complete School Profile" do
      let(:completed_profile) { create(:school_profile, :completed) }

      subject do
        described_class.new(completed_profile.bookings_school.urn, completed_profile)
      end

      it { is_expected.to be_kind_of described_class }
    end

    context "with partially complete School Profile" do
      let(:incomplete_profile) { create(:school_profile) }

      it "will raise an exception" do
        expect {
          described_class.new(incomplete_profile.bookings_school.urn, incomplete_profile)
        }.to raise_exception Bookings::ProfilePublisher::IncompleteSourceProfileError
      end
    end
  end

  describe '#update!' do
    include_context 'with phases'

    let(:school) { create(:bookings_school, :with_subjects, :primary) }
    let(:school_profile) { create(:school_profile, :completed, :with_subjects) }

    context "for School without Profile" do
      subject { described_class.new(school, school_profile).update! }

      it { is_expected.to be_kind_of Bookings::Profile }
      it { is_expected.to be_persisted }
      it { is_expected.to be_valid }
      it { is_expected.to have_attributes(primary_phase: true, secondary_phase: true) }
      it { expect(subject.school.subject_ids).to eql(school_profile.subject_ids) }
      it { expect(subject.school.phase_ids.length).to eql(4) }
    end

    context "for School with Profile" do
      before do
        @initial_profile = create(:bookings_profile, school: school)
      end

      subject { described_class.new(school, school_profile).update! }

      it { is_expected.to be_kind_of Bookings::Profile }
      it { is_expected.to be_persisted }
      it { is_expected.to be_valid }
      it { is_expected.to eql @initial_profile }
      it { is_expected.to have_attributes(primary_phase: true, secondary_phase: true) }
      it { expect(subject.school.subject_ids).to eql(school_profile.subject_ids) }
      it { expect(subject.school.phase_ids.length).to eql(4) }
    end
  end
end
