module GitisContactHelper
  def gitis_contact_display_address(contact)
    [
      contact.address_line1,
      contact.address_line2.presence,
      contact.address_line3.presence,
      contact.address_city,
      contact.address_state_or_province,
      contact.address_postcode,
    ].compact.join(", ")
  end

  def gitis_contact_full_name(contact)
    if contact.is_a?(Bookings::Gitis::MissingContact)
      contact.full_name
    else
      "#{contact.first_name} #{contact.last_name}"
    end
  end
end
