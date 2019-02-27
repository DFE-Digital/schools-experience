require 'rails_helper'

describe Candidates::Registrations::PlacementRequest, type: :model do
  it { is_expected.to have_db_column(:date_start).of_type(:date).with_options null: false }
  it { is_expected.to have_db_column(:date_end).of_type(:date).with_options null: false }
  it { is_expected.to have_db_column(:objectives).of_type(:text).with_options null: false }
  it { is_expected.to have_db_column(:urn).of_type(:integer).with_options null: false }
  it { is_expected.to have_db_column(:degree_stage).of_type(:string).with_options null: false }
  it { is_expected.to have_db_column(:degree_stage_explaination).of_type :text }
  it { is_expected.to have_db_column(:degree_subject).of_type(:string).with_options null: false }
  it { is_expected.to have_db_column(:teaching_stage).of_type(:string).with_options null: false }
  it { is_expected.to have_db_column(:subject_first_choice).of_type(:string).with_options null: false }
  it { is_expected.to have_db_column(:subject_second_choice).of_type(:string).with_options null: false }
  it { is_expected.to have_db_column(:has_dbs_check).of_type(:boolean).with_options null: false }

  it_behaves_like 'a placement preference'
  it_behaves_like 'a subject preference'
  it_behaves_like 'a background check'

  context '.create_from_registration_session' do
    context 'invalid session' do
      let :invalid_session do
        Candidates::Registrations::RegistrationSession.new \
          "registration" => {
            "candidates_registrations_background_check" => {},
            "candidates_registrations_contact_information" => {},
             "candidates_registrations_placement_preference" => {},
             "candidates_registrations_subject_preference" => {}
          }
      end

      it 'raises a validation error' do
        expect {
          described_class.create_from_registration_session! invalid_session
        }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context 'valid session' do
      include_context 'Stubbed candidates school'

      let :registration_session do
        FactoryBot.build :registration_session
      end

      it 'creates the placement request' do
        expect {
          described_class.create_from_registration_session! registration_session
        }.to change { described_class.count }.by 1
      end
    end
  end
end
