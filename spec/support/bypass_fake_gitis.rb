shared_context "bypass fake Gitis" do
  before { Rails.application.config.x.fake_crm = false }
  after { Rails.application.config.x.fake_crm = true }
end
