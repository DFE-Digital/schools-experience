require 'rails_helper'

RSpec.describe Bookings::ProfilePublisher, type: :model do
  describe "#new" do
    context "with complete School Profile" do
      subject do
        described_class.new(completed_profile.bookings_school.urn, completed_profile)
      end

      let(:completed_profile) { create(:school_profile, :completed) }


      it { is_expected.to be_a described_class }
    end

    context "with partially complete School Profile" do
      let(:incomplete_profile) { create(:school_profile) }

      it "raises an exception" do
        expect {
          described_class.new(incomplete_profile.bookings_school.urn, incomplete_profile)
        }.to raise_exception Bookings::ProfilePublisher::IncompleteSourceProfileError
      end
    end
  end

  describe '#update!' do
    include_context 'with phases'

    let(:school) { create(:bookings_school, :with_subjects, :primary) }

    let(:school_profile) do
      create(:school_profile, :completed, :with_subjects)
    end

    context "for School without Profile" do
      subject { described_class.new(school, school_profile).update! }

      it { is_expected.to be_a Bookings::Profile }
      it { is_expected.to be_persisted }
      it { is_expected.to be_valid }
      it { is_expected.to have_attributes(primary_phase: true, secondary_phase: true) }
      it { expect(subject.school.subject_ids.sort).to eql(school_profile.subject_ids.sort) }
      it { expect(subject.school.phase_ids.length).to be(4) }
    end

    context "for School with Profile" do
      subject { described_class.new(school, school_profile).update! }

      before do
        @initial_profile = create(:bookings_profile, school: school)
      end


      it { is_expected.to be_a Bookings::Profile }
      it { is_expected.to be_persisted }
      it { is_expected.to be_valid }
      it { is_expected.to eql @initial_profile }
      it { is_expected.to have_attributes(primary_phase: true, secondary_phase: true) }
      it { expect(subject.school.subject_ids.sort).to eql(school_profile.subject_ids.sort) }
      it { expect(subject.school.phase_ids.length).to be(4) }
    end
  end
end
