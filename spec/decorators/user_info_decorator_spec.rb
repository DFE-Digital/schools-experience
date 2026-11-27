require "rails_helper"

RSpec.describe UserInfoDecorator do
  subject(:decorator) { described_class.new(user_info) }

  let(:user_info) do
    OpenIDConnect::ResponseObject::UserInfo.new(sub: "33333333-4444-5555-6666-777777777777")
  end

  it "returns the OIDC sub as id" do
    expect(decorator.id).to eq(user_info.sub)
  end
end
