require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::DFESignInAPI::Organisations do
  include_context "logged in DfE user"

  subject { Schools::DFESignInAPI::Organisations.new(user_guid) }

  describe '#schools' do
    specify 'schools should match the API request content' do
      expect(subject.schools).to eql(
        dfe_signin_school_data
          .each
          .with_object({}) do |school, h|
            h[school.fetch(:urn).to_i] = school.fetch(:name)
          end
      )
    end

    specify 'urns should match the API request content' do
      expect(subject.urns).to match_array(dfe_signin_school_data.map { |s| s[:urn] })
    end
  end
end
