shared_context "logged in DfE user" do
  before do
    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:session).and_return(current_user: {name: "joey"})
  end
end
