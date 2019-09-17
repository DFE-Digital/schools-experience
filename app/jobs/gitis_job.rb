class GitisJob < ApplicationJob
private

  def gitis_token
    Bookings::Gitis::Auth.new.token
  end

  def gitis
    Bookings::Gitis::CRM.new gitis_token
  end
end
