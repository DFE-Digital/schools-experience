# This controller allows sessions to be set up without requirng
# DfE Signin, for use in testing environments
#
# **It should only be used by Cucumber**
class Schools::InsecureSessionsController < ApplicationController
  def create
    fail unless Rails.env.servertest? || Rails.env.test?

    Bookings::School.find_or_create_by(urn: 123456) do |school|
      school.name = "Some school"
      school.contact_email = "someone@someschool.org"
      school.address_1 = "22 something street"
      school.postcode = "M1 2JJ"
      school.school_type = Bookings::SchoolType.find_or_create_by(name: "type one")
    end

    session[:id_token]     = 'abc123'
    session[:current_user] = OpenIDConnect::ResponseObject::UserInfo.new(given_name: 'Martin', family_name: 'Prince')
    session[:urn]          = 123456
    redirect_to '/schools/dashboard'
  end
end
