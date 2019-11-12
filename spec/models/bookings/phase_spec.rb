require 'rails_helper'

RSpec.describe Bookings::Phase, type: :model do
  describe 'Columns' do
    it { is_expected.to have_db_column(:supports_subjects).of_type(:boolean).with_options(default: true, null: false) }
  end

  describe "Validation" do
    context "Name" do
      it { is_expected.to validate_presence_of(:name) }
      it do
        is_expected.to validate_length_of(:name)
          .is_at_least(2)
          .is_at_most(32)
      end
    end
  end

  describe "Indices" do
    it { is_expected.to(have_db_index(:name).unique(true)) }
  end

  describe "Relationsips" do
    specify do
      is_expected.to(
        have_many(:bookings_schools_phases)
          .class_name("Bookings::SchoolsPhase")
          .with_foreign_key(:bookings_phase_id)
          .inverse_of(:bookings_phase)
      )
    end

    specify do
      is_expected.to(
        have_many(:schools)
          .through(:bookings_schools_phases)
          .class_name("Bookings::School")
          .source(:bookings_school)
      )
    end
  end
end
