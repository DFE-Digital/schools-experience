require 'rails_helper'

describe Bookings::School, type: :model do
  describe 'Scopes' do
    subject { Bookings::School }

    context 'Full text searching on Name' do
      # provided by FullTextSearch
      it { is_expected.to respond_to(:search_by_name) }
    end

    context 'Geographic searching by Coordinates' do
      # provided by FullTextSearch
      it { is_expected.to respond_to(:close_to) }
    end
  end

  describe 'Validation' do
    context 'Name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_most(128) }
    end
  end

  describe 'Relationships' do
    specify do
      is_expected.to(
        have_many(:bookings_schools_subjects)
          .class_name("Bookings::SchoolsSubject")
          .with_foreign_key(:bookings_school_id)
          .inverse_of(:bookings_school)
      )
    end

    specify do
      is_expected.to(
        have_many(:subjects)
          .through(:bookings_schools_subjects)
          .class_name("Bookings::Subject")
          .source(:bookings_subject)
      )
    end
  end
end
