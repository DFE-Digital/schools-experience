require 'rails_helper'

RSpec.describe Candidate::SchoolsController, type: :request do

 context "GET #index" do
   context "Without search params" do
     before { get candidate_schools_path }

     it "returns http success" do
       expect(response).to have_http_status(:success)
     end

     it "includes the search form" do
       expect(response.body).to match(/Find.*placement/i)
     end

     it "excludes the search results" do
       expect(response.body).to_not match(/School experience placements near/i)
     end
   end

    context "With search params" do
      before { get candidate_schools_path(candidate_school: {query: 'manchester'}) }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "excludes the search form" do
        expect(response.body).to_not match(/Find.*placements/i)
      end

      it "excludes the search form" do
        expect(response.body).to match(/School experience placements near/i)
      end
    end
  end

  context "GET #show" do
  #  it "returns http success" do
 #     get :show, id: '123456'
  #    expect(response).to have_http_status(:success)
  #  end
  end

end
