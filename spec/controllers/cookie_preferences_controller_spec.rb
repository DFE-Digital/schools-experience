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
    context "with invalid" do
      before { patch cookie_preference_path }
      it { expect(subject.body).to match 'Edit your cookie settings' }
    end
  end
end
