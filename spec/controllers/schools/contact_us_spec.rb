require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::ContactUsController, type: :request do
  shared_examples 'return to manage' do
    it "has a 'Return to manage school experience' button" do
      expect(subject.search(".govuk-button").any? { |button| button.content == "Go to dashboard" }).to be(false)
      expect(subject.search(".govuk-button").any? { |button| button.content == "Return to manage school experience" }).to be(true)
    end
  end

  shared_examples 'return to dashboard' do
    it "has a 'Go to dashboard' button" do
      expect(subject.search(".govuk-button").any? { |button| button.content == "Go to dashboard" }).to be(true)
      expect(subject.search(".govuk-button").any? { |button| button.content == "Return to manage school experience" }).to be(false)
    end
  end

  subject do
    get schools_contact_us_path
    Nokogiri.parse(response.body)
  end

  context "when signed in" do
    include_context "logged in DfE user"

    include_examples "return to dashboard"
  end

  context "when signed in with school profile" do
    include_context "logged in DfE user for school with profile"

    include_examples "return to dashboard"
  end

  context "when not signed in" do
    include_examples "return to manage"
  end
end
