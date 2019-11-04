require 'rails_helper'

RSpec.describe "candidates/schools/index.html.erb", type: :view do
  let!(:primary_phase) { create :bookings_phase, :primary }
  let!(:secondary_phase) { create :bookings_phase, :secondary }
  let!(:college_phase) { create :bookings_phase, :college }

  context 'with fresh search' do
    before do
      assign(:search, Candidates::SchoolSearch.new)
      render
    end
  end

  before do
    allow(Candidates::School).to receive(:subjects).and_return(
      [[1, 'Computer science'], [2, 'Maths'], [3, 'English']]
    )

    @school = build(:bookings_school)
    @search = Candidates::SchoolSearch.new(
      query: query,
      age_group: age_group,
      max_fee: max_fee,
      subjects: subject_ids
    )
    allow(@search).to receive(:results).and_return(Kaminari.paginate_array([@school]).page(1))

    assign :search, @search

    render
  end

  context 'filtering existing search' do
    let(:query) { 'Manchester' }
    let(:age_group) { 'secondary' }
    let(:max_fee) { '60' }
    let(:subject_ids) { %w{1 3} }

    it "shows search results" do
      expect(rendered).to match(/School experience matching/)
      expect(rendered).to have_css '#search-results'
    end

    it "shows filled in subject filter" do
      expect(rendered).to have_css '#search-filter'
      expect(rendered).to have_checked_field 'subjects[]', count: 2
      expect(rendered).to have_unchecked_field 'subjects[]', count: 1
    end

    it "shows results" do
      expect(rendered).to have_css '.school-result'
      expect(rendered).to have_css '.school-result h2', text: @school.name
      expect(rendered).to have_css '.school-result .govuk-summary-list__key', count: 3
    end
  end

  context 'Layout' do
    let(:query) { 'Manchester' }
    let(:max_fee) { '60' }
    let(:subject_ids) { nil }

    context 'Search for primary experience' do
      let(:age_group) { 'primary' }

      it 'hides the subjects filters' do
        expect(rendered).not_to have_css '#search-filter'
      end
    end

    context 'Search for secondary experience' do
      let(:age_group) { 'secondary' }

      it 'shows the subjects filters' do
        expect(rendered).to have_css '#search-filter'
      end
    end
  end
end
