module GitisAccess
  def gitis_crm
    Bookings::Gitis::CRM.new('a-token')
  end
end
