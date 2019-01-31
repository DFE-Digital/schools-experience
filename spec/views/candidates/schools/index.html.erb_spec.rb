require 'rails_helper'

RSpec.describe "candidates/schools/index.html.erb", type: :view do
  context 'with fresh search' do
    before do
      assign(:search, Candidates::SchoolSearch.new)
      render
    end

    it "shows search form" do
      expect(rendered).to match(/Find.*placements/i)
    end
  end

  context 'filtering existing search' do
    before do
      assign :search, Candidates::SchoolSearch.new(
        query: 'Manchester',
        phase: ['16-18'],
        fees: '<60',
        subject: ['Computer science', 'Physical education']
      )

      render
    end

    it "shows search results" do
      expect(rendered).to match(/School experience placements near/)
      expect(rendered).to have_css '#search-results'
    end

    it "shows filled in filter" do
      expect(rendered).to have_css '#search-filter'
      expect(rendered).to have_checked_field 'subject[]', count: 2
    end
  end
end
