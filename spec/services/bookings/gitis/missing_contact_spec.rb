require 'rails_helper'

describe Bookings::Gitis::MissingContact do
  subject { described_class.new uuid }

  let(:uuid) { SecureRandom.uuid }

  it { is_expected.to have_attributes contactid: uuid, id: uuid }
  it { is_expected.to have_attributes firstname: 'Unavailable' }
  it { is_expected.to have_attributes lastname: 'Unavailable' }
  it { is_expected.to have_attributes first_name: 'Unavailable' }
  it { is_expected.to have_attributes full_name: 'Unavailable' }
  it { is_expected.to have_attributes emailaddress1: nil }
  it { is_expected.to have_attributes emailaddress2: nil }
  it { is_expected.to have_attributes email: nil }
end
