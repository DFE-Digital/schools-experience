module GitisAccess
  def gitis_token
    Bookings::Gitis::Auth.new.token
  end

  def gitis_crm
    Bookings::Gitis::CRM.new(gitis_token)
  end
end
