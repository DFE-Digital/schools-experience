FactoryBot.define do
  factory :admin_contact, class: Schools::OnBoarding::AdminContact do
    email { 'g.chalmers@springfield.edu' }
    email2 { 's.skinner@springfield.edu' }
    phone { '+441234567890' }
  end
end
