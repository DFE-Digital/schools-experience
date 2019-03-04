require 'rails_helper'

describe Candidates::Registrations::RegistrationSession::StepNotFound do
  context '#step_path' do
    let :model do
      FactoryBot.build :contact_information
    end

    subject do
      described_class.new model.model_name.param_key
    end

    it 'returns the path to build the correct model' do
      expect(subject.step_path).to eq \
        'new_candidates_school_registrations_contact_information_path'
    end
  end
end
