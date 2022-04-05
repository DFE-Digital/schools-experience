require 'rails_helper'

RSpec.describe "candidates/schools/show", type: :view do
  let(:urn) { create(:bookings_school).urn }
  let(:school) { Candidates::School.find(urn) }

  context 'with profile' do
    let(:profile) { create(:bookings_profile, school: school) }
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
      link = new_candidates_school_registrations_personal_information_path(school)
      expect(rendered).to have_css("a.govuk-button[href=\"#{link}\"]")
    end

    it "will include dress code information" do
      expect(rendered).to have_css("#dress-code")
    end

    it "has a start request button" do
      expect(rendered).to have_css("a.govuk-button", text: 'Start request')
    end

    context 'with availability' do
      it "doesn't have a banner to promote the search page" do
        expect(rendered).not_to have_css("div.govuk-inset-text > a", text: 'Search for schools offering school experience')
      end
    end

    context 'without availability' do
      let(:urn) { create(:bookings_school, :without_availability).urn }

      it "has a banner to promote the search page" do
        allow(school).to receive(:has_availability?).and_return(false)

        expect(rendered).to have_css("div.govuk-inset-text", text: 'This school does not have any placements available at the moment.')
        expect(rendered).to have_css("div.govuk-inset-text > a", text: 'Search for schools offering school experience')
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

    it "has a banner to promote the search page" do
      expect(rendered).to have_css("div.govuk-inset-text", text: 'This school has not yet joined the Get school experience service.')
      expect(rendered).to have_css("div.govuk-inset-text > a", text: 'Search for schools offering school experience')
    end

    it "doesn't render the imported flex dates" do
      expect(rendered).not_to have_css("#placement-availability")
      expect(rendered).not_to have_css("#school-experience-type")
    end
  end
end
