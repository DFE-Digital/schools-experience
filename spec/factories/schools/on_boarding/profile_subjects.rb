FactoryBot.define do
  factory :schools_on_boarding_profile_subject, class: 'Schools::OnBoarding::ProfileSubject' do
    schools_school_profile { nil }
    bookings_subject { nil }
  end
end
