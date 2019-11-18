require 'rails_helper'

describe CookiePreferencesController, type: :request do
  subject { response }

  describe "#show" do
    before { get cookie_preference_path }
    it { is_expected.to redirect_to(edit_cookie_preference_path) }
  end

  describe "#edit" do
    before { get edit_cookie_preference_path }
    it { expect(subject.body).to match 'Edit your cookie settings' }
  end

  describe "#update" do
    before { patch cookie_preference_path, params: params }

    context "with valid" do
      let(:params) { { cookie_preference: { analytics: false } } }
      it { is_expected.to redirect_to edit_cookie_preference_path }
      it "Should set cookies to persist settings"
    end

    context "with invalid" do
      let(:params) { { cookie_preference: {} } }
      it { expect(subject.body).to match 'Edit your cookie settings' }
    end
  end
end
