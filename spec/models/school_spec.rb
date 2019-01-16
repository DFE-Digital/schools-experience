require 'rails_helper'

RSpec.describe School, type: :model do

  describe 'Validation' do

    context 'Name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_most(128) }
    end

  end

end
