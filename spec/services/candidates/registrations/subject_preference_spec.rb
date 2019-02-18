require 'rails_helper'

describe Candidates::Registrations::SubjectPreference, type: :model do
  it_behaves_like 'a registration step'
  it_behaves_like 'a subject preference'
end
