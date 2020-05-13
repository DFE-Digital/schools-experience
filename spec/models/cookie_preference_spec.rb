require 'rails_helper'

describe CookiePreference, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe 'attributes' do
    it { is_expected.to be_persisted }
    it { is_expected.to respond_to :analytics }
    it { is_expected.to respond_to :required }
    it { is_expected.to have_attributes required: true }

    context 'required should be editable' do
      before { subject.required = false }
      it { is_expected.to have_attributes required: true }
    end
  end

  describe 'validations' do
    context 'for analytics' do
      it { is_expected.to allow_value(true).for(:analytics) }
      it { is_expected.to allow_value(false).for(:analytics) }

      it do
        is_expected.not_to allow_value(nil).for(:analytics)
          .with_message('Choose On or Off for cookies which measure website use')
      end
    end
  end

  describe 'methods' do
    before { freeze_time }
    it { is_expected.to have_attributes cookie_key: 'cookie_preference-v1' }
    it { is_expected.to have_attributes expires: 1.year.from_now }
  end

  describe '#all=' do
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

  describe '#to_json' do
    subject { described_class.new.to_json }
    it { is_expected.to eql({ 'analytics' => nil, 'required' => true }.to_json) }
  end

  describe '.from_json' do
    let(:json) { { analytics: true }.to_json }
    subject { described_class.from_json(json) }
    it { is_expected.to have_attributes analytics: true }
  end

  describe '.from_cookie' do
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

  describe '.all_cookies' do
    subject { described_class.all_cookies }

    it do
      is_expected.to eql \
        %w[_ga _gat _gid ai_session ai_user analytics_tracking_uuid]
    end
  end

  describe '#accepted_cookies' do
    subject { preference.accepted_cookies }

    context 'with analytics accepted' do
      let(:preference) { described_class.new(analytics: true) }

      it do
        is_expected.to eql \
          %w[_ga _gat _gid ai_session ai_user analytics_tracking_uuid]
      end
    end

    context 'with analytics rejected' do
      let(:preference) { described_class.new(analytics: false) }
      it { is_expected.to be_empty }
    end
  end

  describe '#rejected_cookies' do
    subject { preference.rejected_cookies }

    context 'with analytics accepted' do
      let(:preference) { described_class.new(analytics: true) }
      it { is_expected.to be_empty }
    end

    context 'with analytics accepted' do
      let(:preference) { described_class.new(analytics: false) }

      it do
        is_expected.to eql \
          %w[_ga _gat _gid ai_session ai_user analytics_tracking_uuid]
      end
    end
  end

  describe '.category' do
    subject { described_class.category '_ga' }
    it { is_expected.to eql(:analytics) }
  end

  describe '.allowed?' do
    context 'with cookie name' do
      subject { described_class.new(params).allowed?('_ga') }

      context 'for neither accepted nor rejected' do
        let(:params) { {} }
        it { is_expected.to be true }
      end

      context 'for accepted' do
        let(:params) { { analytics: true } }
        it { is_expected.to be true }
      end

      context 'for rejected' do
        let(:params) { { analytics: false } }
        it { is_expected.to be false }
      end
    end

    context 'with category' do
      subject { described_class.new(params).allowed?(:analytics) }

      context 'without neither accepted or rejected' do
        let(:params) { {} }
        it { is_expected.to be true }
      end

      context 'with accepted' do
        let(:params) { { analytics: true } }
        it { is_expected.to be true }
      end

      context 'with rejected' do
        let(:params) { { analytics: false } }
        it { is_expected.to be false }
      end
    end
  end
end
