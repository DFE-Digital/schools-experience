require 'rails_helper'

describe GitisContactHelper, type: :helper do
  describe "#gitis_contact_display_phone" do
    context "with a Gitis::Booking::Contact" do
      it "returns contact.phone" do
        contact = build(:gitis_contact)
        expect(helper.gitis_contact_display_phone(contact)).to eq(contact.phone)
      end
    end

    context "with a GetIntoTeachingApiClient::SchoolsExperienceSignUp" do
      it "returns first non-nil of secondary_telephone, telephone then mobile_telephone" do
        contact = build(:api_schools_experience_sign_up, telephone: nil, secondary_telephone: nil)
        expect(helper.gitis_contact_display_phone(contact)).to eq(contact.mobile_telephone)

        contact.telephone = "11111111"
        expect(helper.gitis_contact_display_phone(contact)).to eq(contact.telephone)

        contact.secondary_telephone = "22222222"
        expect(helper.gitis_contact_display_phone(contact)).to eq(contact.secondary_telephone)
      end
    end
  end

  describe "#gitis_contact_display_address" do
    context "with a Gitis::Booking::Contact" do
      it "returns contact.address" do
        contact = build(:gitis_contact)
        expect(helper.gitis_contact_display_address(contact)).to eq(contact.address)
      end
    end

    context "with a GetIntoTeachingApiClient::SchoolsExperienceSignUp" do
      it "returns the formatted address" do
        contact = build(:api_schools_experience_sign_up)
        address = helper.gitis_contact_display_address(contact)
        expect(address).to eq(
          "3 Main Street, Botchergate, Carlisle, Cumbria, TE7 1NG"
        )
      end
    end
  end
end
