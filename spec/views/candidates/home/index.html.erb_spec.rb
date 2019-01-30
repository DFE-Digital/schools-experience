require 'rails_helper'

RSpec.describe "candidates/home/index.html.erb", type: :view do
  before { render }

  it "will show a button" do
    expect(rendered).to match '>Start now</a>'
  end
end
