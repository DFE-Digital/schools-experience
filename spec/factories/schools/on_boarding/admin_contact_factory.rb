FactoryBot.define do
  factory :admin_contact, class: Schools::OnBoarding::AdminContact do
    email { 'g.chalmers@springfield.edu' }
    email_secondary { 's.skinner@springfield.edu' }
    phone { '+441234567890' }
  end
end
