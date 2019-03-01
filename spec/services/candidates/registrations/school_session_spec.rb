require 'rails_helper'

describe Candidates::Registrations::SchoolSession do
  let :school_urn_1 do
    100001
  end

  let :school_urn_2 do
    100002
  end

  let :contact_information_1 do
    FactoryBot.build :contact_information
  end

  let :contact_information_2 do
    FactoryBot.build :contact_information, full_name: 'Someone Else'
  end

  let :session do
    {}
  end

  context '#current_registration' do
    context '1 school' do
      subject do
        described_class.new school_urn_1, session
      end

      before do
        subject.current_registration.save contact_information_1
      end

      it 'returns the current_registration' do
        expect(subject.current_registration.contact_information).to eq \
          contact_information_1
      end

      it 'stores the registration in the session' do
        expect(session).to eq "schools/#{school_urn_1}/registrations" => {
          contact_information_1.model_name.param_key => contact_information_1.attributes
        }
      end
    end

    context 'multiple schools' do
      let :school_session_1 do
        described_class.new school_urn_1, session
      end

      let :school_session_2 do
        described_class.new school_urn_2, session
      end

      before do
        school_session_1.current_registration.save contact_information_1
        school_session_2.current_registration.save contact_information_2
      end

      it 'returns the correct current_registration for each school session' do
        expect(school_session_1.current_registration.contact_information).to eq \
          contact_information_1

        expect(school_session_2.current_registration.contact_information).to eq \
          contact_information_2
      end

      it 'stores the registratiosn for each school seperatley' do
        expect(session).to eq \
          "schools/#{school_urn_1}/registrations" => {
            contact_information_1.model_name.param_key => contact_information_1.attributes
          },
          "schools/#{school_urn_2}/registrations" => {
            contact_information_2.model_name.param_key => contact_information_2.attributes
          }
      end
    end
  end
end
