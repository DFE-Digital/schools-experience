require 'rails_helper'

describe Candidates::Registrations::AccountCheck, type: :model do
  it_behaves_like 'a registration step'

  it { is_expected.to respond_to :full_name }
  it { is_expected.to respond_to :email }

  it { is_expected.to validate_presence_of :full_name }
  it { is_expected.to validate_presence_of :email }
end
