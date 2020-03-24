require 'rails_helper'

RSpec.describe "candidates/school_searches/new.html.erb", type: :view do
  let(:whitelist) { '' }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('COVID_URN_WHITELIST').and_return(whitelist)
    assign(:search, Candidates::SchoolSearch.new)
    render
  end

  it "shows search form" do
    expect(rendered).to have_css('h1', text: 'Search for school experience')
  end

  specify 'the form has the correct inputs' do
    expect(rendered).to have_css('label', text: 'Enter location or postcode')
    expect(rendered).to have_css('label', text: 'Select search area')

    expect(rendered).to have_css("input#location[required='required']")
    expect(rendered).to have_css('select#distance')

    expect(rendered).to have_button('Search')
  end

  context 'when whitelisting schools' do
    let(:whitelist) { '1' }

    specify 'the form has the correct inputs' do
      expect(rendered).to have_css('label', text: 'Enter location or postcode')
      expect(rendered).not_to have_css('label', text: 'Select search area')

      expect(rendered).to have_css("input#location[required='required']")
      expect(rendered).not_to have_css('select#distance')
    end
  end
end
