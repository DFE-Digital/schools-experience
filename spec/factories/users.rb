FactoryBot.define do
  factory :user do
    sub { SecureRandom.uuid }
  end
end
