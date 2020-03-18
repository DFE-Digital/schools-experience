shared_examples 'an implementation of a Gitis store' do
  it { is_expected.to respond_to :find }
  it { is_expected.to respond_to :fetch }
  it { is_expected.to respond_to :write }
  it { is_expected.to respond_to :write! }
end
