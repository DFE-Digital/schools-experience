require 'rails_helper'

describe "Displaying the cookie banner", type: :request do
  let(:cookie_name) { 'seen_cookie_message' }
  let(:banner_contents) { /School experience uses cookies/ }

  context 'on the first visit (when the seen_cookie_message cookie is absent)' do
    specify "the cookie should be set to 'yes'" do
      expect(cookies[cookie_name]).to be_nil
      get candidates_root_path
      expect(cookies[cookie_name]).to eql('yes')
    end

    specify 'the page should display the cookie banner' do
      get candidates_root_path
      expect(response.body).to match(banner_contents)
    end
  end

  context 'on subsequent visits (when the seen_cookie_message is present)' do
    before { cookies[cookie_name] = 'yes' }

    specify 'the page should not display the cookie banner' do
      get candidates_root_path
      expect(response.body).not_to match(banner_contents)
    end
  end
end
