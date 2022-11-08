require "rails_helper"

RSpec.describe Role, type: :model do
  describe "relationships" do
    it { is_expected.to have_and_belong_to_many(:users).join_table(:users_roles) }
    it { is_expected.to belong_to(:resource).optional }
  end

  describe "validation rules" do
    it { is_expected.to validate_inclusion_of(:resource_type).in_array(Rolify.resource_types).allow_nil }
  end
end
