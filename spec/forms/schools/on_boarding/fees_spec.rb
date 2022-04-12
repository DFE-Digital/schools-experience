require 'rails_helper'

describe Schools::OnBoarding::Fees, type: :model do
  context '#attributes' do
    it { is_expected.to respond_to :selected_fees }
    it { is_expected.to respond_to :dbs_fees_specified }
  end

  describe 'default values' do
    it { expect(subject.dbs_fees_specified).to be(true) }
  end

  context 'validations' do
    describe "#selected_fees" do
      context "when no options are selected" do
        subject do
          described_class.new(selected_fees: [])
        end

        it { expect(subject.invalid?).to be true }
      end

      context "when fees and no fees are selected" do
        subject do
          described_class.new(selected_fees: %w[administration_fees none])
        end

        it { expect(subject.invalid?).to be true }
      end
    end
  end

  describe ".compose" do
    subject { described_class.compose(false, true, false) }

    it "assigns selected fees" do
      expect(subject.selected_fees).to eq %w[dbs_fees]
    end
  end
end
