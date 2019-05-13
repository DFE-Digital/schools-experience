require 'rails_helper'

describe Schools::OnBoarding::DBSFee, type: :model do
  it_behaves_like 'a school fee'

  context '#interval' do
    it 'defaults to "One-off"' do
      expect(described_class.new.interval).to eq 'One-off'
    end

    it 'validates interval is "One-off"' do
      errors = described_class.new(interval: 'Daily').tap(&:validate).errors[:interval]
      expect(errors).to eq ["must be 'One-off'"]
    end
  end
end
