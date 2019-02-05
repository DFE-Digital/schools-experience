require 'rails_helper'

describe Candidates::Registrations::ApplicationPreview do
  let! :placement_date_start do
    Date.tomorrow
  end

  let! :placement_date_end do
    placement_date_start + 7.days
  end

  let :access_needs do
    true
  end

  let :access_needs_details do
    'Access needs'
  end

  let :has_dbs_check do
    true
  end

  let :valid_registraion_session do
    {
      "candidates_registrations_account_check" => {
        "full_name" => "Testy McTest",
        "email" => "test@example.com"
      },
      "candidates_registrations_placement_preference" => {
        "date_start" => placement_date_start.strftime('%Y-%m-%d'),
        "date_end" => placement_date_end.strftime('%Y-%m-%d'),
        "objectives" => "test the software",
        "access_needs" => access_needs,
        "access_needs_details" => access_needs_details
      },
      "candidates_registrations_address" => {
        "building" => "Test building",
        "street" => "Test street",
        "town_or_city" => "Test town",
        "county" => "Testshire",
        "postcode" => "TE57 1NG",
        "phone" => "01234567890"
      },
      "candidates_registrations_subject_preference" => {
        "degree_stage" => "I don't have a degree and am not studying for one",
        "degree_stage_explaination" => "",
        "degree_subject" => "Not applicable",
        "teaching_stage" => "I'm thinking about teaching and want to find out more",
        "subject_first_choice" => "Architecture",
        "subject_second_choice" => "Mathematics"
      },
      "candidates_registrations_background_check" => {
        "has_dbs_check" => has_dbs_check
      }
    }
  end

  subject { described_class.new valid_registraion_session }

  context '#full_name' do
    it 'returns the correct value' do
      expect(subject.full_name).to eq "Testy McTest"
    end
  end

  context '#full_address' do
    it 'returns the correct value' do
      expect(subject.full_address).to eq <<-ADDRESS.squish
        Test building, Test street, Test town, Testshire, TE57 1NG
      ADDRESS
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

  context '#school' do
    it 'returns the correct value' do
      expect(subject.school).to eq "SCHOOL_STUB"
    end
  end

  context '#placement_availability' do
    it 'returns the correct value' do
      expect(subject.placement_availability).to eq \
        placement_date_start.strftime('%d %B %Y') + ' to ' +
        placement_date_end.strftime('%d %B %Y')
    end
  end

  context '#placement_outcome' do
    it 'returns the correct value' do
      expect(subject.placement_outcome).to eq "test the software"
    end
  end

  context '#access_needs' do
    context 'with access needs' do
      let :access_needs do
        true
      end

      let :access_needs_details do
        'Access needs'
      end

      it 'returns the correct value' do
        expect(subject.access_needs).to eq access_needs_details
      end
    end

    context 'without access needs' do
      let :access_needs do
        false
      end

      it 'returns the correct value' do
        expect(subject.access_needs).to eq "None"
      end
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
      expect(subject.teaching_subject_second_choice).to eq "Mathematics"
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
end
