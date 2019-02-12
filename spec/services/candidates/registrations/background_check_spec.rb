require 'rails_helper'

describe Candidates::Registrations::BackgroundCheck, type: :model do
  it_behaves_like 'a registration step'

  context 'attributes' do
    it { is_expected.to respond_to :has_dbs_check }
  end
end
