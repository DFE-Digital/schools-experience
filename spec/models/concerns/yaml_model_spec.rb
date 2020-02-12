require 'rails_helper'
describe YamlModel, type: :model do
  class YamlTestModel
    include YamlModel

    pk_attribute :dob, :date
    attribute :firstname, :string
    attribute :lastname, :string
  end

  let(:described_class) { YamlTestModel }

  describe '.data_path' do
    it "should be assigned" do
      expect(described_class.send(:data_path)).to eql \
        Rails.root.join('data', 'yaml_test_models')
    end
  end

  context 'with test data' do
    before do
      allow(described_class).to receive(:data_path).and_return \
        Rails.root.join('spec', 'sample_data', 'yaml_test_models')
    end

    let(:test_dob) { '19780101' }
    let(:second_dob) { '19900101' }

    describe '.find' do
      subject { described_class.find test_dob }
      it { is_expected.to have_attributes dob: Date.parse('1978-01-01') }
      it { is_expected.to have_attributes firstname: 'James' }
      it { is_expected.to have_attributes lastname: 'Smith' }
    end

    describe '.keys' do
      subject { described_class.keys }
      it { is_expected.to eql [test_dob, second_dob] }
    end

    describe '#==' do
      let(:attrs) { { dob: '19800620', firstname: 'Sarah', lastname: 'Jane' } }
      let(:other) { described_class.new attrs }
      subject { described_class.new attrs }
      it { is_expected.to eq other }
    end

    describe '.all' do
      let(:first) { described_class.find test_dob }
      let(:second) { described_class.find second_dob }
      subject { described_class.all }
      it { is_expected.to eq [first, second] }
    end
  end
end
