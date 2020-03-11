FactoryBot.define do
  factory :service_update do
    sequence(:date) { |n| 4.years.ago + n.days }
    sequence(:title) { |n| "Service Update #{n}" }
    summary { 'This is a short summary of a service update' }
    html_content do
      "<p>This is the longer content</p>\n\n<p>Description of Service updates.</p>"
    end
  end
end
