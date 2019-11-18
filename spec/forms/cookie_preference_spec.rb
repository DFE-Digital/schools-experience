require 'rails_helper'

describe CookiePreference, type: :model do
  context 'attributes' do
    it { is_expected.to be_persisted }
    it { is_expected.to respond_to :analytics }
    it { is_expected.to respond_to :required }
    it { is_expected.to have_attributes required: true }
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

    context 'for required' do
      it { is_expected.to validate_acceptance_of(:required) }
    end
  end
end
