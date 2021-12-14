require 'rails_helper'

RSpec.describe "candidates/schools/index.html.erb", type: :view do
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
      expect(rendered).to have_css('.govuk-fieldset__heading', text: 'Disability and access needs')
      expect(rendered).to have_css '#search-filter input[name="disability_confident"]'
    end

    it "shows results" do
      expect(rendered).to have_css '.school-result'
      expect(rendered).to have_css '.school-result h2', text: @school.name
      expect(rendered).to have_css '.school-result .govuk-summary-list__key', count: 4
    end

    context 'when filtered only by the dbs policy' do
      let(:subjects) { [] }
      let(:phases) { [] }
      let(:max_fee) { '' }

      it "shows the filter tag" do
        expect(rendered).to have_css 'div', text: 'DBS check: Not required'
      end
    end
  end
end
