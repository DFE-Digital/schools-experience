require 'rails_helper'

describe Candidates::Registrations::RegistrationAsPlacementRequest do
  let :session do
    build :flattened_registration_session
  end

  let(:urn) { 11048 }
  subject { described_class.new session }
  let(:school) { create(:bookings_school, urn: urn) }

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

  let!(:expected_attributes) do
    {
      "has_dbs_check" => true,
      "availability" => "Every third Tuesday",
      "bookings_placement_date_id" => nil,
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

  context '#attributes' do
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
