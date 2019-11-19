require 'rails_helper'

describe CookiePreference, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  context 'attributes' do
    it { is_expected.to be_persisted }
    it { is_expected.to respond_to :analytics }
    it { is_expected.to respond_to :required }
    it { is_expected.to have_attributes required: true }

    context 'required should be editable' do
      before { subject.required = false }
      it { is_expected.to have_attributes required: true }
    end
  end

  context 'validations' do
    context 'for analytics' do
      it { is_expected.to allow_value(true).for(:analytics) }
      it { is_expected.to allow_value(false).for(:analytics) }

      it do
        is_expected.not_to allow_value(nil).for(:analytics).
          with_message('Choose On or Off for cookies which measure website use')
      end
    end
  end

  context 'methods' do
    before { freeze_time }
    it { is_expected.to have_attributes cookie_key: 'cookie_preference-v1' }
    it { is_expected.to have_attributes expires: 30.days.from_now }
  end

  context '#all=' do
    subject { described_class.new(all: all) }

    context 'with true' do
      let(:all) { true }
      it { is_expected.to have_attributes required: true }
      it { is_expected.to have_attributes analytics: true }
    end

    context 'with 1' do
      let(:all) { '1' }
      it { is_expected.to have_attributes required: true }
      it { is_expected.to have_attributes analytics: true }
    end

    context 'with something else' do
      let(:all) { '0' }
      it { is_expected.to have_attributes required: true }
      it { is_expected.to have_attributes analytics: nil }
    end
  end

  context '#to_json' do
    subject { described_class.new.to_json }
    it { is_expected.to eql({ 'analytics' => nil, 'required' => true }.to_json) }
  end

  context '.from_json' do
    let(:json) { { analytics: true }.to_json }
    subject { described_class.from_json(json) }
    it { is_expected.to have_attributes analytics: true }
  end

  context '.from_cookie' do
    subject { described_class.from_cookie(cookie) }

    context 'with cookie' do
      let(:cookie) { { analytics: true }.to_json }
      it { is_expected.to have_attributes analytics: true }
    end

    context 'without cookie' do
      let(:cookie) { nil }
      it { is_expected.to have_attributes analytics: nil }
    end
  end
end
