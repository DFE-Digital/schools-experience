require 'rails_helper'

RSpec.describe Bookings::Subject, type: :model do
  describe "Validation" do
    context "Name" do
      it { is_expected.to validate_presence_of(:name) }
      it do
        is_expected.to validate_length_of(:name)
          .is_at_least(2)
          .is_at_most(64)
      end

      context 'Uniqueness' do
        subject { create(:bookings_subject) }
        it { is_expected.to validate_uniqueness_of(:name) }
      end
    end
  end

  describe "Relationsips" do
    specify do
      is_expected.to(
        have_many(:bookings_schools_subjects)
          .class_name("Bookings::SchoolsSubject")
          .with_foreign_key(:bookings_subject_id)
          .inverse_of(:bookings_subject)
      )
    end

    specify do
      is_expected.to(
        have_many(:schools)
          .through(:bookings_schools_subjects)
          .class_name("Bookings::School")
          .source(:bookings_school)
      )
    end

    specify do
      is_expected.to have_many(:placement_date_subjects).dependent(:destroy)
    end

    specify do
      is_expected.to have_many(:onboarding_profile_subjects).dependent(:destroy)
    end

    specify do
      is_expected.to have_many(:placement_requests)
        .with_foreign_key(:bookings_subject_id)
    end
  end

  describe "Scopes" do
    describe 'default_scope' do
      let!(:visible) { create(:bookings_subject, hidden: false) }
      let!(:hidden) { create(:bookings_subject, hidden: true) }

      subject { described_class.all.to_a }

      it 'should include non-hidden subjects' do
        is_expected.to include(visible)
      end

      it 'should not include hidden subjects' do
        is_expected.not_to include(hidden)
      end
    end

    describe '.secondary' do
      let!(:secondary) { create(:bookings_subject, secondary_subject: true) }
      let!(:primary) { create(:bookings_subject, secondary_subject: false) }

      subject { described_class.secondary_subjects.to_a }

      it 'should include secondary subjects' do
        is_expected.to include(secondary)
      end

      it 'should not include non-secondary subjects' do
        is_expected.not_to include(primary)
      end
    end
  end
end
