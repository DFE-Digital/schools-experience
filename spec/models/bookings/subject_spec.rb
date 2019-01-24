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
  end
end
