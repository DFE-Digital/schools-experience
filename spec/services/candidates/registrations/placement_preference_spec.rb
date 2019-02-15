require 'rails_helper'

describe Candidates::Registrations::PlacementPreference, type: :model do
  it_behaves_like 'a registration step'
  it_behaves_like 'a placement preference'
end
