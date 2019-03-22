require 'rails_helper'

RSpec.describe "candidates/schools/index.html.erb", type: :view do
  context 'with fresh search' do
    before do
      assign(:search, Candidates::SchoolSearch.new)
      render
    end

    it "shows search form" do
      expect(rendered).to match(/Find.*experience/i)
    end
  end

  context 'filtering existing search' do
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
        phases: %w{3},
        max_fee: '60',
        subjects: %w{1 3}
      )
      allow(@search).to receive(:results).and_return(Kaminari.paginate_array([@school]).page(1))

      assign :search, @search

      render
    end

    it "shows search results" do
      expect(rendered).to match(/School experience matching/)
      expect(rendered).to have_css '#search-results'
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

    it "shows results" do
      expect(rendered).to have_css '.school-result'
      expect(rendered).to have_css '.school-result h3', text: @school.name
      expect(rendered).to have_css '.school-result .govuk-summary-list__key', count: 4
    end
  end
end
