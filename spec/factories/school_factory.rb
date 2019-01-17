FactoryBot.define do
  factory :school, class: School do
    sequence(:name) {|n| "school #{n}"}
  end
end
