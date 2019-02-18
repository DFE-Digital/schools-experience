shared_examples 'a background check' do
  context 'attributes' do
    it { is_expected.to respond_to :has_dbs_check }
  end
end
