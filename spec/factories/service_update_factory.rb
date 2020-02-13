FactoryBot.define do
  factory :service_update do
    sequence(:date) { |n| 4.years.ago + n.days }
    sequence(:title) { |n| "Service Update #{n}" }
    summary { 'This is a short summary of a service update' }
    content { "This is the longer content\n\nDescription of Service updates." }
  end
end
