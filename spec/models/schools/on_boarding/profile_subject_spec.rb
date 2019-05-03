require 'rails_helper'

describe Schools::OnBoarding::ProfileSubject, type: :model do
  it { is_expected.to belong_to :school_profile }
  it { is_expected.to belong_to :subject }
  it { is_expected.to validate_presence_of :school_profile }
  it { is_expected.to validate_presence_of :subject }
end
