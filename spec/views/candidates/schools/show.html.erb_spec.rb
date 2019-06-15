require 'rails_helper'

RSpec.describe "candidates/schools/show.html.erb", type: :view do
  let(:urn) { create(:bookings_school).urn }
  let(:school) { Candidates::School.find(urn) }

  context 'with profile' do
    let(:profile) { build(:bookings_profile, school: school) }
    let(:presenter) { Candidates::SchoolPresenter.new(school, profile) }

    before do
      assign :school, school
      assign :presenter, presenter
      render
    end

    it "will include the schools name" do
      expect(rendered).to have_css('h1', text: school.name)
    end

    it "will provide a link to apply" do
      link = new_candidates_school_registrations_contact_information_path(school)
      expect(rendered).to have_css("a.govuk-button[href=\"#{link}\"]")
    end

    it "will include dress code information" do
      expect(rendered).to have_css("#dress-code")
    end

    it "has two start request buttons with appropriate responsive classes" do
      %w(school-start-request-button__tablet_plus school-start-request-button__mobile).each do |css_class|
        expect(rendered).to have_css("div.#{css_class} > a", text: 'Start request')
      end
    end
  end

  context 'without profile' do
    before do
      assign :school, school
      render
    end

    it "will include the schools name" do
      expect(rendered).to have_css('h1', text: school.name)
    end

    it "will provide a link to apply" do
      link = new_candidates_school_registrations_contact_information_path(school)
      expect(rendered).to have_css("a.govuk-button[href=\"#{link}\"]")
    end

    it "has two start request buttons with appropriate responsive classes" do
      %w(school-start-request-button__tablet_plus school-start-request-button__mobile).each do |css_class|
        expect(rendered).to have_css("div.#{css_class} > a", text: 'Start request')
      end
    end
  end
end
