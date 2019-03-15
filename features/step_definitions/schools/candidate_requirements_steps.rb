Given("I outline our dbs policy") do
  fill_in 'Outline your DBS policy in 50 words or fewer.', with: 'policy details'
end

Given("I choose {string} from the {string}") do |string, string2|
  choose 'Yes'
end

Given("I provide details") do
  fill_in 'Provide detail', with: 'Candidates need to be good'
end
