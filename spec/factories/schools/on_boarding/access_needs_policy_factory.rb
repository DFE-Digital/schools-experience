FactoryBot.define do
  factory :access_needs_policy, class: Schools::OnBoarding::AccessNeedsPolicy do
    has_access_needs_policy { true }
    url { 'https://example.com/access-needs-policy' }
  end
end
