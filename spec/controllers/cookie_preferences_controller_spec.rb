require 'rails_helper'

describe CookiePreferencesController, type: :request do
  describe "#show" do
    subject! { get cookie_preference_path }
    it { expect(response).to redirect_to(edit_cookie_preference_path) }
  end
end
