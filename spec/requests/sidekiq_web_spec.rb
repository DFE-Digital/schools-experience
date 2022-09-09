require "rails_helper"

describe "Sidekiq Web UI", type: :request do
  subject do
    get sidekiq_web_path
    response
  end

  # We can't test the production use case explicitly as the
  # routes are already mounted, but this provides a partial
  # safety net.
  it { is_expected.to have_http_status(:unauthorized) }
end
