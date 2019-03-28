require 'rails_helper'

RSpec.describe "candidates/school_searches/new.html.erb", type: :view do
  before do
    assign(:search, Candidates::SchoolSearch.new)
    render
  end

  it "shows search form" do
    expect(rendered).to match(/Find.*experience/i)
  end

  specify 'the form has the correct inputs' do
    expect(rendered).to have_css('label', text: 'Where?')
    expect(rendered).to have_css('label', text: 'Distance')

    expect(rendered).to have_css('input#location')
    expect(rendered).to have_css('select#distance')

    expect(rendered).to have_button('Find')
  end
end
