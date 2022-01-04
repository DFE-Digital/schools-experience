require 'rails_helper'

describe GitisContactHelper, type: :helper do
  describe "#gitis_contact_display_address" do
    it "returns the formatted address" do
      contact = build(:api_schools_experience_sign_up_with_name)
      address = helper.gitis_contact_display_address(contact)
      expect(address).to eq(
        "3 Main Street, Botchergate, Carlisle, Cumbria, TE7 1NG"
      )
    end
  end

  describe "#gitis_contact_full_name" do
    it "returns the full name" do
      contact = build(:api_schools_experience_sign_up_with_name)
      full_name = helper.gitis_contact_full_name(contact)
      expect(full_name).to eq("#{contact.first_name} #{contact.last_name}")
    end

    context "when given a Bookings::Gitis::MissingContact" do
      it "returns 'Unavailable'" do
        contact = Bookings::Gitis::MissingContact.new(firstname: "First", lastname: "Last")
        full_name = helper.gitis_contact_full_name(contact)
        expect(full_name).to eq("Unavailable")
      end
    end
  end
end
