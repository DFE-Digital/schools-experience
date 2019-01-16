FactoryBot.define do
  factory :school do
    sequence(:name) {|n| "school #{n}"}
  end
end
