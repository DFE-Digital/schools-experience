require 'rails_helper'

describe Bookings::PlacementRequest::Cancellation, type: :model do
  it { is_expected.to belong_to :placement_request }
  it { is_expected.to have_db_column(:reason).of_type(:text).with_options null: false }
  it { is_expected.to validate_presence_of :reason }
end
