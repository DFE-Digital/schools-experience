require 'rails_helper'

describe Candidates::Registrations::ApplicationPreview do
  let :has_dbs_check do
    true
  end

  let :contact_information do
    double Candidates::Registrations::ContactInformation,
      full_name: 'Testy McTest',
      email: 'test@example.com',
      date_of_birth: Date.parse('2000-01-01'),
      building: "Test building",
      street: "Test street",
      town_or_city: "Test town",
      county: "Testshire",
      postcode: "TE57 1NG",
      phone: "01234567890"
  end

  let :background_check do
    double Candidates::Registrations::BackgroundCheck,
      has_dbs_check: has_dbs_check
  end

  let :placement_preference do
    double Candidates::Registrations::PlacementPreference,
      objectives: "test the software",
      availability: 'From Epiphany to Whitsunday'
  end

  let(:school) { build(:bookings_school) }

  let :subject_preference do
    double Candidates::Registrations::SubjectPreference,
      degree_stage: "I don't have a degree and am not studying for one",
      degree_stage_explaination: "",
      degree_subject: "Not applicable",
      teaching_stage: "I'm thinking about teaching and want to find out more",
      subject_first_choice: "Architecture",
      subject_second_choice: "Maths",
      school_name: 'Test school',
      school: school
  end

  let :registration_session do
    double Candidates::Registrations::RegistrationSession,
      contact_information: contact_information,
      placement_preference: placement_preference,
      subject_preference: subject_preference,
      background_check: background_check
  end

  subject do
    described_class.new registration_session
  end

  context '#full_name' do
    it 'returns the correct value' do
      expect(subject.full_name).to eq "Testy McTest"
    end
  end

  context '#full_address' do
    it 'returns the correct value' do
      expect(subject.full_address).to eq \
        "Test building, Test street, Test town, Testshire, TE57 1NG"
    end
  end

  context '#telephone_number' do
    it 'returns the correct value' do
      expect(subject.telephone_number).to eq "01234567890"
    end
  end

  context '#email_address' do
    it 'returns the correct value' do
      expect(subject.email_address).to eq "test@example.com"
    end
  end

  context '#date_of_birth' do
    it 'returns the correct value' do
      expect(subject.date_of_birth).to eq '01/01/2000'
    end
  end

  context '#school' do
    it 'returns the correct value' do
      expect(subject.school).to eq school
    end
  end

  context '#school_name' do
    it 'returns the correct value' do
      expect(subject.school_name).to eq "Test school"
    end
  end

  context '#placement_outcome' do
    it 'returns the correct value' do
      expect(subject.placement_outcome).to eq "test the software"
    end
  end

  context '#degree_stage' do
    it 'returns the correct value' do
      expect(subject.degree_stage).to eq \
        "I don't have a degree and am not studying for one"
    end
  end

  context '#degree_subject' do
    it 'returns the correct value' do
      expect(subject.degree_subject).to eq "Not applicable"
    end
  end

  context '#teaching_stage' do
    it 'returns the correct value' do
      expect(subject.teaching_stage).to eq \
        "I'm thinking about teaching and want to find out more"
    end
  end

  context '#teaching_subject_first_choice' do
    it 'returns the correct value' do
      expect(subject.teaching_subject_first_choice).to eq "Architecture"
    end
  end

  context '#teaching_subject_second_choice' do
    it 'returns the correct value' do
      expect(subject.teaching_subject_second_choice).to eq "Maths"
    end
  end

  context '#dbs_check_document' do
    context 'with dbs check document' do
      let :has_dbs_check do
        true
      end

      it 'returns the correct value' do
        expect(subject.dbs_check_document).to eq "Yes"
      end
    end

    context 'without dbs check document' do
      let :has_dbs_check do
        false
      end

      it 'returns the correct value' do
        expect(subject.dbs_check_document).to eq "No"
      end
    end
  end

  context 'placement dates' do
    context 'when school has flexible dates' do
      let(:pa) { 'From Epiphany to Whitsunday' }
      context '#placement_availability' do
        it 'returns the correct value' do
          expect(subject.placement_availability).to eq pa
        end
      end

      context '#placement_availability_description' do
        it 'returns the #placement_availability when it is present' do
          expect(subject.placement_availability_description).to eq pa
        end
      end
    end

    context 'when school has fixed dates' do
      let(:pd) { '02 May 2019' }
      let :placement_preference do
        double Candidates::Registrations::PlacementPreference,
          objectives: "test the software",
          placement_date: pd,
          availability: nil
      end

      context '#placement_availability' do
        it 'returns the correct value' do
          expect(subject.placement_date).to eq pd
        end
      end

      context '#placement_availability_description' do
        it 'returns the placement date when #placement_availability is absent' do
          expect(subject.placement_availability_description).to eq pd
        end
      end
    end
  end
end
