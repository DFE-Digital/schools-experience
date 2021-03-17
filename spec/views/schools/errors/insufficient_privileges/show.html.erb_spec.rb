require 'rails_helper'

describe 'schools/errors/insufficient_privileges/show.html.erb' do
  subject { render && response }

  before { assign "organisation_access_url", "/organisation" }

  context "without school" do
    it { is_expected.to have_css "h1", text: "Request school experience access" }
    it { is_expected.to have_css "h2", text: "Request access to an organisation" }
    it { is_expected.to have_link "Request organisation access" }
  end
end
