shared_context "Degree subject autocomplete" do
  before do
    allow(ENV).to receive(:fetch)
    .with("DEGREE_SUBJECT_AUTOCOMPLETE_ENABLED", false)
    .and_return(degree_subject_autocomplete_flag)
  end
end

shared_context "Degree subject autocomplete enabled" do
  include_context "Degree subject autocomplete"
  let(:degree_subject_autocomplete_flag) { "1" }
end

shared_context "Degree subject autocomplete disabled" do
  include_context "Degree subject autocomplete"
  let(:degree_subject_autocomplete_flag) { "0" }
end
