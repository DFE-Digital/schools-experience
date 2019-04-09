require 'rails_helper'

describe Schools::OnBoarding::Fees, type: :model do
  context '#attributes' do
    it { is_expected.to respond_to :administration_fees }
    it { is_expected.to respond_to :dbs_fees }
    it { is_expected.to respond_to :other_fees }
  end

  context 'validations' do
    it { is_expected.not_to allow_value(nil).for :administration_fees }
    it { is_expected.not_to allow_value(nil).for :dbs_fees }
    it { is_expected.not_to allow_value(nil).for :other_fees }
  end
end
