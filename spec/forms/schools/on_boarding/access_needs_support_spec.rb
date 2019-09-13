require 'rails_helper'

describe Schools::OnBoarding::AccessNeedsSupport, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :supports_access_needs }
  end
end
