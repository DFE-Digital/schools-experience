shared_context "bypass fake Gitis" do
  before { allow(Rails.application.config.x.gitis).to receive(:fake_crm).and_return(false) }
end
