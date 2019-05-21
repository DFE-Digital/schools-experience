FactoryBot.define do
  factory :bookings_profile, class: 'Bookings::Profile' do
    association :school, factory: :bookings_school
    dbs_required { 'never' }
    primary_phase { true }
    secondary_phase { false }
    college_phase { false }
    key_stage_early_years { false }
    key_stage_1 { false }
    key_stage_2 { true }
    dress_code_business { false }
    dress_code_cover_tattoos { false }
    dress_code_remove_piercings { false }
    dress_code_smart_casual { false }
    parking_provided { false }
    parking_details { 'nearby' }
    start_time { '09:00' }
    end_time { '16:00' }
    flexible_on_times { false }
    experience_details { 'some info' }
    admin_contact_full_name { 'some one' }
    admin_contact_email { 'some@one.com' }
    admin_contact_phone { '07123456789' }
    description_details { 'A rather short description of our school' }
  end
end
