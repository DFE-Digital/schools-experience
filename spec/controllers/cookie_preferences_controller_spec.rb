require 'rails_helper'

describe CookiePreferencesController, type: :request do
  let(:cookie_name) { 'cookie_preference-v1' }
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

      it do
        expect(cookies[cookie_name]).to \
          eql({ 'analytics' => false, 'required' => true }.to_json)
      end
      it { expect(cookies['analytics_tracking_uuid']).to be_blank }
    end

    context "with all" do
      let(:params) { { cookie_preference: { all: 'true' } } }
      it { is_expected.to redirect_to edit_cookie_preference_path }

      it do
        expect(cookies[cookie_name]).to \
          eql({ 'analytics' => true, 'required' => true }.to_json)
      end
    end

    context "with invalid" do
      let(:params) { { cookie_preference: {} } }
      it { expect(subject.body).to match 'Edit your cookie settings' }
      it { expect(cookies[cookie_name]).to be_nil }
    end
  end
end
