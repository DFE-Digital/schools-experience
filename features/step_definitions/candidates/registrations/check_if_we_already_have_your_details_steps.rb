Then("I should see a paragraph informing me I can speed up my placement request") do
  within('#main-content') do
    ["Get Into Teaching website", "speed up your placement request"].each do |snippet|
      expect(page).to have_content(snippet)
    end
  end
end

Then("the paragraph should contain a {string} link to {string}") do |link, href|
  within('#main-content') do
    expect(page).to have_link(link, href: href)
  end
end
