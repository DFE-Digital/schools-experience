require 'rails_helper'

RSpec.feature "Feedback", type: :feature do
  scenario "a bot submitting feedback (filling in the honeypot)" do
    visit new_candidates_feedback_path

    choose "Make a school experience request"
    choose "Yes"
    choose "Satisfied"
    fill_in "If you are a human, ignore this field", with: "i-am-a-bot"

    click_on "Submit feedback"

    expect(page.status_code).to eq(200)
    expect(page.body).to eq("")
  end
end
