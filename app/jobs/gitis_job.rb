class GitisJob < ApplicationJob
private

  def gitis
    Bookings::Gitis::Factory.crm
  end
end
