require 'rails_helper'

feature "Save the referer" do
  scenario "a user accepts the cookies from invalid path" do
    visit new_candidates_feedback_path

    click_on "Submit feedback"
    click_on "Accept analytics cookies"

    expect(page.current_path).to eq(root_path)
  end

  scenario "a user accepts the cookies from valid path" do
    visit candidates_signin_path

    click_on "Accept analytics cookies"

    expect(page.current_path).to eq(candidates_signin_path)
  end

  scenario "a user accepts the cookies from a blacklisted path" do
    visit edit_cookie_preference_path

    click_on "Accept analytics cookies"

    expect(page.current_path).to eq(edit_cookie_preference_path)
  end
end
