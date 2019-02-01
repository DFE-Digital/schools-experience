require 'rails_helper'

describe Candidate::Registrations::AccountCheck, type: :model do
  it { is_expected.to respond_to :full_name }
  it { is_expected.to respond_to :email }

  it { is_expected.to validate_presence_of :full_name }
  it { is_expected.to validate_presence_of :email }
end
