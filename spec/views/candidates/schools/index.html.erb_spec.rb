require 'rails_helper'

RSpec.describe "candidates/schools/index", type: :view do
  context 'with fresh search' do
    before do
      assign(:search, Candidates::SchoolSearch.new)
      render
    end
  end

  context 'filtering existing search' do
    let(:phases) { %w[3] }
    let(:max_fee) { '60' }
    let(:subjects) { %w[1 3] }
    let(:dbs_policies) { %w[2] }
    let(:disability_confident) { '1' }
    let(:parking) { '1' }

    before do
      allow(Candidates::School).to receive(:subjects).and_return(
        [[1, 'Computer science'], [2, 'Maths'], [3, 'English']]
      )

      allow(Candidates::School).to receive(:phases).and_return(
        [[1, 'Primary'], [2, 'Seconday'], [3, '16 to 18']]
      )

      @school = build(:bookings_school)
      @search = Candidates::SchoolSearch.new(
        query: 'Manchester',
        phases: phases,
        max_fee: max_fee,
        subjects: subjects,
        dbs_policies: dbs_policies
      )
      allow(@search).to receive(:results).and_return(Kaminari.paginate_array([@school]).page(1))

      assign :search, @search

      @facet_tags = FacetTagsPresenter.new(@search.applied_filters)
      assign :facet_tags, @facet_tags

      render
    end

    it "shows search results" do
      expect(rendered).to match(/School experience matching/)
      expect(rendered).to have_css '#search-results'
    end

    it "shows the search bar" do
      expect(rendered).to have_css '#search-bar'
      expect(rendered).to have_css 'input#location-field'
      expect(rendered).to have_css 'button[type="submit"]'
    end

    it "shows filled in subject filter" do
      expect(rendered).to have_css '#search-filter'
      expect(rendered).to have_checked_field 'subjects[]', count: 2
      expect(rendered).to have_unchecked_field 'subjects[]', count: 1
    end

    it "shows filled in phases filter" do
      expect(rendered).to have_css '#search-filter'
      expect(rendered).to have_checked_field 'phases[]', count: 1
      expect(rendered).to have_unchecked_field 'phases[]', count: 2
    end

    it "shows the dbs filter" do
      expect(rendered).to have_css('.govuk-label', text: 'DBS check')
      expect(rendered).to have_css '#search-filter input[name="dbs_policies[]"]'
    end

    it "shows the disability confident filter" do
      expect(rendered).to have_css('.govuk-fieldset__legend', text: 'Disability and access needs')
      expect(rendered).to have_css '#search-filter input[name="disability_confident"]'
    end

    it "shows the parking filter" do
      expect(rendered).to have_css('.govuk-fieldset__legend', text: 'Parking')
      expect(rendered).to have_css '#search-filter input[name="parking"]'
    end

    it "shows results" do
      expect(rendered).to have_css '.school-result'
      expect(rendered).to have_css '.school-result h2', text: @school.name
      expect(rendered).to have_css '.school-result .govuk-summary-list__key', count: 4
    end

    it "shows facet tags" do
      expect(rendered).to have_css '.facet-tags'
      expect(rendered).to have_css '.facet-tags .facet-tags__wrapper', count: 4
    end

    context 'when filtered only by the dbs policy' do
      let(:subjects) { [] }
      let(:phases) { [] }
      let(:max_fee) { '' }

      it "shows the filter tag" do
        expect(rendered).to have_css 'div', text: 'DBS check: Not required'
      end

      it "shows facet tag" do
        expect(rendered).to have_css '.facet-tags'
        expect(rendered).to have_css '.facet-tags .facet-tags__wrapper', count: 1
      end
    end
  end

  context "sorted by distance tag" do
    before do
      @search = Candidates::SchoolSearch.new
      @facet_tags = FacetTagsPresenter.new(@search.applied_filters)
      allow(@search).to receive(:results).and_return(Kaminari.paginate_array(schools).page(1))

      render
    end

    context "when more than one result is returned" do
      let(:schools) { [build(:bookings_school), build(:bookings_school)] }

      it "shows when more than one result" do
        expect(rendered).to have_css 'div', text: 'Sorted by distance'
      end
    end

    context "when less than two results are returned" do
      let(:schools) { [build(:bookings_school)] }

      it "shows when more than one result" do
        expect(rendered).to_not have_css 'div', text: 'Sorted by distance'
      end
    end
  end

  context "when no results and expanded search" do
    shared_examples "a non-England search" do
      before do
        @search = Candidates::SchoolSearch.new
        @facet_tags = FacetTagsPresenter.new(@search.applied_filters)

        geocoding_response = Geocoder::Result::Test.new(address_components: [long_name: country])
        country = GeocodingResponseCountry.new(geocoding_response)
        assign(:country, country)
        assign(:expanded_search_radius, true)

        render
      end

      it "show a message and link to get more information about teacher training" do
        expect(rendered).to have_css('h2', text: 'This service is for schools in England')
        expect(rendered).to have_link(link_text, href: href)
      end
    end

    context "when other region search" do
      context "when search result is Wales" do
        let(:country) { "Wales" }
        let(:link_text) { 'Learn more about teacher training in Wales' }
        let(:href) { 'https://educators.wales/teachers' }

        it_behaves_like "a non-England search"
      end

      context "when search result is Scotland" do
        let(:country) { "Scotland" }
        let(:link_text) { 'Learn more about teacher training in Scotland' }
        let(:href) { 'https://teachinscotland.scot/' }

        it_behaves_like "a non-England search"
      end

      context "when search result is Northern Ireland" do
        let(:country) { "Northern Ireland" }
        let(:link_text) { 'Learn more about teacher training in Northern Ireland' }
        let(:href) { 'https://www.education-ni.gov.uk/articles/initial-teacher-education-courses-northern-ireland' }

        it_behaves_like "a non-England search"
      end

      context "when search result is unknown" do
        let(:country) { "Canada" }

        it "shows a message" do
          @search = Candidates::SchoolSearch.new
          @facet_tags = FacetTagsPresenter.new(@search.applied_filters)

          geocoding_response = Geocoder::Result::Test.new(address_components: [long_name: country])
          country = GeocodingResponseCountry.new(geocoding_response)
          assign(:country, country)
          assign(:expanded_search_radius, true)

          render

          expect(rendered).to have_css('h2', text: 'This service is for schools in England')
        end
      end
    end
  end
end
