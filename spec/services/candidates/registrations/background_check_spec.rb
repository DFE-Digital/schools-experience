require 'rails_helper'

describe Candidates::Registrations::BackgroundCheck, type: :model do
  it_behaves_like 'a registration step'
  it_behaves_like 'a background check'
end
