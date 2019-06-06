require 'rails_helper'

RSpec.describe "candidates/dashboards/show.html.erb", type: :view do
  before { render }

  it { expect(rendered).to have_css('h1', text: 'Your requests and bookings') }
end
