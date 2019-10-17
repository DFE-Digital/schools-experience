require 'rails_helper'

describe Candidates::Registrations::SchoolSession do
  let :school_urn_1 do
    100001
  end

  let :school_urn_2 do
    100002
  end

  let :personal_information_1 do
    FactoryBot.build :personal_information
  end

  let :personal_information_2 do
    FactoryBot.build :personal_information, first_name: 'Someone', last_name: 'Else'
  end

  let :session do
    {}
  end

  context '.destroy_all_registrations' do
    let :session do
      {
        'schools/100/registrations' => {
          'personal_information' => {
            'first_name'    => 'One',
            'last_name'     => 'Test',
            'email'         => 'one@test.one',
            'date_of_birth' => Date.parse('1980-01-01')
          }
        },
        'schools/200/registrations' => {
          'personal_information' => {
            'first_name'    => 'Two',
            'last_name'     => 'Test',
            'email'         => 'two@test.two',
            'date_of_birth' => Date.parse('1980-01-01')
          },
        },
        'some-other-key' => 'test'
      }
    end

    before { described_class.delete_all_registrations session }
    subject { session }

    it "will remove the registrations keys" do
      is_expected.not_to include('schools/100/registrations')
      is_expected.not_to include('schools/200/registrations')
    end

    it "will leave the other keys" do
      is_expected.to include('some-other-key' => 'test')
    end
  end

  context '#current_registration' do
    context '1 school' do
      subject do
        described_class.new(school_urn_1, session).current_registration
      end

      before do
        subject.save personal_information_1
      end

      it { is_expected.to be_kind_of Candidates::Registrations::RegistrationSession }

      it 'returns the current_registration' do
        expect(subject.personal_information).to eq \
          personal_information_1
      end

      it 'stores the registration in the session' do
        expect(session).to eq "schools/#{school_urn_1}/registrations" => \
          personal_information_1.attributes_to_persist.merge('urn' => school_urn_1)
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
        school_session_1.current_registration.save personal_information_1
        school_session_2.current_registration.save personal_information_2
      end

      it 'returns the correct current_registration for each school session' do
        expect(school_session_1.current_registration.personal_information).to eq \
          personal_information_1

        expect(school_session_2.current_registration.personal_information).to eq \
          personal_information_2
      end

      it 'stores the registrations for each school seperatley' do
        expect(session).to eq \
          "schools/#{school_urn_1}/registrations" => \
            personal_information_1.attributes_to_persist.merge('urn' => school_urn_1),
          "schools/#{school_urn_2}/registrations" => \
              personal_information_2.attributes_to_persist.merge('urn' => school_urn_2)
      end
    end

    context 'with a gitis_contact' do
      let(:gitis_contact) { build(:gitis_contact, :persisted) }

      subject do
        described_class.new(school_urn_1, session).current_registration(gitis_contact)
      end

      before do
        subject.save personal_information_1
      end

      it { is_expected.to be_kind_of Candidates::Registrations::GitisRegistrationSession }

      it 'returns the current_registration' do
        expect(subject.personal_information.email).to eq gitis_contact.email
      end

      it 'stores the registration in the session' do
        expect(session["schools/#{school_urn_1}/registrations"]).to \
          include('urn' => school_urn_1)

        expect(session["schools/#{school_urn_1}/registrations"]).to \
          include(personal_information_1.attributes_to_persist)
      end
    end
  end
end
