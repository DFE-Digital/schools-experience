require 'rails_helper'

describe Candidates::Registrations::RegistrationAsPlacementRequest do
  # It's a date not a time,
  # it just makes comparisions with date_end/date_start easier and we don't
  # care too much about the registration_session's updated/created_at timestamps
  CURRENT_TIME = Date.today

  let :session do
    FactoryBot.build :registration_session, current_time: CURRENT_TIME
  end

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

  EXPECTED_ATTRIBUTES = {
    "has_dbs_check" => true,
    "date_start" => (CURRENT_TIME + 3.days),
    "date_end" => (CURRENT_TIME + 4.days),
    "objectives" => "test the software",
    "degree_stage" => "I don't have a degree and am not studying for one",
    "degree_stage_explaination" => "",
    "degree_subject" => "Not applicable",
    "teaching_stage" => "I'm thinking about teaching and want to find out more",
    "subject_first_choice" => "Architecture",
    "subject_second_choice" => "Mathematics",
    "urn" => 11048,
  }.freeze

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
        expect(subject.attributes).to eq EXPECTED_ATTRIBUTES
      end
    end
  end
end
