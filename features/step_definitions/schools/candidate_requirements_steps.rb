Given("I choose {string} from the {string}") do |option, field|
  choose option, from: field
end

Given("I provide details") do
  fill_in 'Provide detail', with: 'Candidates need to be good'
end
