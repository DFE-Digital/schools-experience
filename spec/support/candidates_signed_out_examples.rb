shared_examples 'candidate signed out' do |req|
  context "when not signed in" do
    before { instance_exec(&req) }

    it "returns http unauthorized" do
      expect(response).to redirect_to(candidates_signin_path)
    end
  end
end
