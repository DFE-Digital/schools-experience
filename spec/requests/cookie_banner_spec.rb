require 'rails_helper'

describe "Displaying the cookie banner", type: :request do
  let(:cookie_name) { 'seen_cookie_message' }
  let(:banner_contents) { /Cookies on the Get school experience service/ }

  context 'on the first visit (when the seen_cookie_message cookie is absent)' do
    specify "the cookie should not be set to 'yes'" do
      expect(cookies[cookie_name]).to be_nil
      get candidates_root_path
      expect(cookies[cookie_name]).to be_nil
    end

    specify 'the page should display the cookie banner' do
      get candidates_root_path
      expect(response.body).to match(banner_contents)
    end
  end

  context 'on subsequent visits (when the cookie_preference is present)' do
    let(:preference) { CookiePreference.new(analytics: true) }
    before { cookies[preference.cookie_key] = { value: preference.to_json } }

    specify 'the page should not display the cookie banner' do
      get candidates_root_path
      expect(response.body).not_to match(banner_contents)
    end
  end
end
