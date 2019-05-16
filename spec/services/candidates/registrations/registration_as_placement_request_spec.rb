require 'rails_helper'

describe Candidates::Registrations::RegistrationAsPlacementRequest do
  let :session do
    FactoryBot.build :registration_session
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
      "degree_stage" => "I don't have a degree and am not studying for one",
      "degree_stage_explaination" => "",
      "degree_subject" => "Not applicable",
      "teaching_stage" => "I’m very sure and think I’ll apply",
      "subject_first_choice" => "Maths",
      "subject_second_choice" => "Physics",
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
