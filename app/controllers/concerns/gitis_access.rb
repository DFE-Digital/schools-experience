module GitisAccess
  def gitis_token
    Bookings::Gitis::Auth.new.token
  end

  def gitis_store
    if Rails.application.config.x.gitis.fake_crm
      Bookings::Gitis::Store::Fake.new
    else
      Bookings::Gitis::Store::Dynamics.new gitis_token
    end
  end

  def gitis_crm
    Bookings::Gitis::CRM.new(gitis_store)
  end
end
