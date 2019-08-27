require 'rails_helper'

RSpec.describe Candidates::SchoolSearchesController, type: :request do
  context "GET #index" do
    before { get new_candidates_school_search_path }

    it "includes the search form" do
      expect(response.body).to match(/Search for school experience/i)
    end
  end
end
