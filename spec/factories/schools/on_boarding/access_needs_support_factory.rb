FactoryBot.define do
  factory :access_needs_support, class: Schools::OnBoarding::AccessNeedsSupport do
    supports_access_needs { true }
  end
end
