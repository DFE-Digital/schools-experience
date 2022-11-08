require "rails_helper"

RSpec.describe User, type: :model do
  let(:dfe_sign_in_user) do
    OpenIDConnect::ResponseObject::UserInfo.new(
      sub: "33333333-4444-5555-6666-777777777777",
      given_name: "John",
      family_name: "Doe",
    )
  end

  it { is_expected.to respond_to(:has_role?) }

  describe ".exchange" do
    subject(:exchange) { described_class.exchange(dfe_sign_in_user) }

    it { expect { exchange }.to change(described_class, :count).by(1) }
    it do
      is_expected.to have_attributes(
        sub: dfe_sign_in_user.sub,
        given_name: dfe_sign_in_user.given_name,
        family_name: dfe_sign_in_user.family_name,
        raw_attributes: dfe_sign_in_user.raw_attributes
      )
    end

    context "when the user already exists" do
      before { create(:user, sub: dfe_sign_in_user.sub) }

      it { expect { exchange }.not_to change(described_class, :count) }
    end
  end
end
