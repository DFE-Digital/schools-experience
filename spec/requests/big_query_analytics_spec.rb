require "rails_helper"

RSpec.describe "BigQuery Analytics", type: :request do
  it "sends a DFE Analytics web request event" do
    expect { get root_path }.to have_sent_analytics_event_types(:web_request)
  end

  it "sends a DFE Analytics entity event" do
    params = { candidates_feedback: build(:candidates_feedback).attributes }
    expect { post "/candidates/feedbacks", params: params }.to have_sent_analytics_event_types(:create_entity)
  end
end
