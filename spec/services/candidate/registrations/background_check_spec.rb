require 'rails_helper'

describe Candidate::Registrations::BackgroundCheck, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :has_dbs_check }
  end
end
