require 'rails_helper'

describe Candidates::Registrations::RegistrationAsPlacementRequest do
  let(:urn) { 11048 }
  subject { described_class.new session }

  PII = {
    "full_name" => 'Testy McTest',
    "email" => 'test@example.com',
    "building" => "Test building",
    "street" => "Test street",
    "town_or_city" => "Test town",
    "county" => "Testshire",
    "postcode" => "TE57 1NG",
    "phone" => "01234567890"
  }.freeze


  context '#attributes' do
    context 'when flexible dates' do
      let(:school) { create(:bookings_school, urn: urn) }

      let :session do
        build :registration_session
      end

      let!(:expected_attributes) do
        {
          "has_dbs_check" => true,
          "availability" => "Every third Tuesday",
          "objectives" => "test the software",
          "degree_stage" => "Other",
          "degree_stage_explaination" => "Khan academy, level 3",
          "degree_subject" => "Bioscience",
          "teaching_stage" => "I’m very sure and think I’ll apply",
          "subject_first_choice" => "Astronomy",
          "subject_second_choice" => "History",
          "urn" => urn,
          "bookings_school_id" => school.id
        }
      end

      context 'PII' do
        # Redundant given the next spec, but going for clarity!
        PII.each do |k, _|
          it "removes #{k}" do
            expect(subject.attributes[k]).to eq nil
          end
        end
      end

      context 'Non PII' do
        it 'returns the expected attributes for the session' do
          expect(subject.attributes).to eq(expected_attributes)
        end
      end
    end

    context 'when fixed dates' do
      let :school do
        create :bookings_school, urn: urn, availability_preference_fixed: true
      end

      let :placement_date do
        create :bookings_placement_date
      end

      let :session do
        build :registration_session,
          :with_placement_date,
          placement_date: placement_date
      end

      let!(:expected_attributes) do
        {
          "has_dbs_check" => true,
          "availability" => nil,
          "bookings_placement_date_id" => placement_date.id,
          "bookings_placement_dates_subject_id" => nil,
          "objectives" => "test the software",
          "degree_stage" => "Other",
          "degree_stage_explaination" => "Khan academy, level 3",
          "degree_subject" => "Bioscience",
          "teaching_stage" => "I’m very sure and think I’ll apply",
          "subject_first_choice" => "Astronomy",
          "subject_second_choice" => "History",
          "urn" => urn,
          "bookings_school_id" => school.id
        }
      end

      context 'PII' do
        # Redundant given the next spec, but going for clarity!
        PII.each do |k, _|
          it "removes #{k}" do
            expect(subject.attributes[k]).to eq nil
          end
        end
      end

      context 'Non PII' do
        it 'returns the expected attributes for the session' do
          expect(subject.attributes).to eq(expected_attributes)
        end
      end
    end
  end
end
