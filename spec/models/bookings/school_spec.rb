require 'rails_helper'

describe Bookings::School, type: :model do
  describe 'Validation' do
    context 'Name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_most(128) }
    end

    context 'Fee' do
      it { is_expected.to validate_presence_of(:fee) }
      it { is_expected.to validate_numericality_of(:fee).is_greater_than_or_equal_to(0) }
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

    specify do
      is_expected.to(
        have_many(:bookings_schools_phases)
          .class_name("Bookings::SchoolsPhase")
          .with_foreign_key(:bookings_school_id)
          .inverse_of(:bookings_school)
      )
    end

    specify do
      is_expected.to(
        have_many(:phases)
          .through(:bookings_schools_phases)
          .class_name("Bookings::Phase")
          .source(:bookings_phase)
      )
    end
  end

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

    context 'Filtering' do
      let!(:school_a) { create(:bookings_school) }
      let!(:school_b) { create(:bookings_school) }
      let!(:school_c) { create(:bookings_school) }

      context 'By subject' do
        let!(:maths) { create(:bookings_subject, name: "Maths") }
        let!(:physics) { create(:bookings_subject, name: "Physics") }
        let!(:chemistry) { create(:bookings_subject, name: "Chemistry") }
        let!(:biology) { create(:bookings_subject, name: "Biology") }

        before do
          school_a.subjects << [maths, physics]
          school_b.subjects << [maths, chemistry]
          school_c.subjects << [biology]
        end

        context 'when no subjects are supplied' do
          specify 'all schools should be returned' do
            [nil, "", []].each do |empty|
              expect(subject.that_provide(empty)).to include(school_a, school_b, school_c)
            end
          end
        end

        context 'when one or more subjects are supplied' do
          specify 'all schools that match any provided subject are returned' do
            {
              physics              => [school_a],
              maths                => [school_a, school_b],
              chemistry            => [school_b],
              biology              => [school_c],
              [chemistry, biology] => [school_b, school_c],
              [maths, chemistry]   => [school_a, school_b],
              [maths, biology]     => [school_a, school_b, school_c]
            }.each do |subjects, results|
              expect(subject.that_provide(subjects)).to match_array(results)
            end
          end
        end
      end

      context 'By phase' do
        let!(:primary) { create(:bookings_phase, name: "Primary") }
        let!(:secondary) { create(:bookings_phase, name: "Secondary") }
        let!(:college) { create(:bookings_phase, name: "College") }

        before do
          school_a.phases << [primary]
          school_b.phases << [primary, secondary]
          school_c.phases << [college]
        end

        context 'when no phases are supplied' do
          specify 'all schools should be returned' do
            [nil, "", []].each do |empty|
              expect(subject.at_phase(empty)).to include(school_a, school_b, school_c)
            end
          end
        end

        context 'when one or more phases are supplied' do
          specify 'all schools that match any provided phase are returned' do
            {
              primary              => [school_a, school_b],
              secondary            => [school_b],
              college              => [school_c],
              [primary, college]   => [school_a, school_b, school_c],
              [secondary, college] => [school_b, school_c]
            }.each do |phases, results|
              expect(subject.at_phase(phases)).to match_array(results)
            end
          end
        end
      end

      context 'By fees' do
        let!(:school_a) { create(:bookings_school, fee: 0) }
        let!(:school_b) { create(:bookings_school, fee: 20) }
        let!(:school_c) { create(:bookings_school, fee: 40) }

        specify 'should return all schools when no amount provided' do
          [nil, "", []].each do |empty|
            expect(subject.costing_upto(empty)).to include(school_a, school_b, school_c)
          end
        end

        specify 'should return all schools with no fee when amount provided' do
          expect(subject.costing_upto(20)).to include(school_a)
        end

        specify 'should return all schools with a lower equal fee when amount provided' do
          expect(subject.costing_upto(20)).to include(school_a, school_b)
        end

        specify 'should not return schools with a higher fee than provided amount' do
          expect(subject.costing_upto(20)).not_to include(school_c)
        end
      end
    end
  end
end
