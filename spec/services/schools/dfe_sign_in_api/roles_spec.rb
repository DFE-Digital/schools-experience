require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::DFESignInAPI::Roles do
  include_context "logged in DfE user"
  subject { described_class.new(user_guid, dfe_signin_school_urn) }

  before do
    allow_any_instance_of(Schools::DFESignInAPI::Client).to receive(:enabled?).and_return(true)
    allow_any_instance_of(Schools::DFESignInAPI::Client).to receive(:role_check_enabled?).and_return(true)
  end

  specify 'should respond to #has_school_experience_role?' do
    expect(subject).to respond_to(:has_school_experience_role?)
  end

  context '#has_school_experience_role?' do
    context 'when the role is present' do
      let!(:school) { create(:bookings_school, urn: dfe_signin_school_urn) }

      subject { described_class.new(user_guid, dfe_signin_school_urn) }

      specify 'should return true when the role is present' do
        expect(subject.has_school_experience_role?).to be true
      end

      specify 'should save the DfE Sign-in organisation UUID' do
        expect(school.dfe_signin_organisation_uuid).to be nil
        subject.has_school_experience_role?
        expect(school.reload.dfe_signin_organisation_uuid).to eql(dfe_signin_school_id)
      end

      context 'when the DfE Sign-in organisation UUID has been saved' do
        let!(:school) { create(:bookings_school, urn: dfe_signin_school_urn, dfe_signin_organisation_uuid: dfe_signin_school_id) }

        before { allow(subject).to receive(:retrieve_organisation_uuid).and_return(true) }
        before { allow(subject).to receive(:find_organisation_uuid).and_return(dfe_signin_school_id) }
        before { subject.has_school_experience_role? }

        specify 'should find the school to get the organisation uuid' do
          expect(subject).to have_received(:find_organisation_uuid)
        end

        specify 'should not need to contact the DfE Sign-in API' do
          expect(subject).to_not have_received(:retrieve_organisation_uuid)
        end
      end
    end

    context 'when the role is not present' do
      subject { described_class.new(user_guid, dfe_signin_school_urn) }

      before do
        allow(subject).to receive(:roles).and_return([])
      end

      specify 'should return false when the role is absent' do
        expect(subject.has_school_experience_role?).to be false
      end
    end

    context 'when the user is not associated with the organisation' do
      let(:another_urn) { 112233 }

      subject { described_class.new(user_guid, another_urn) }

      specify "should raise an 'no organisation' error" do
        expect { subject.has_school_experience_role? }.to raise_error(Schools::DFESignInAPI::NoOrganisationError, /No organisation ID found for user/)
      end
    end

    context 'when no result is returned' do
      before do
        allow(subject).to receive(:response).and_return(nil)
      end

      subject { described_class.new(user_guid, dfe_signin_school_urn) }

      specify "should raise an 'invalid response' error" do
        expect { subject.has_school_experience_role? }.to raise_error(Schools::DFESignInAPI::APIResponseError, /invalid response from roles API/)
      end
    end
  end
end
