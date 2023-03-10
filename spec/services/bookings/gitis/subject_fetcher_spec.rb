require 'rails_helper'

describe Bookings::Gitis::SubjectFetcher do
  subject { described_class }
  let(:subject_name) { "Maths" }
  let(:subject_id) { 275_000_001 }
  let(:teaching_subjects) do
    [
      build(:api_teaching_subject, id: subject_id, value: subject_name),
    ]
  end
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::LookupItemsApi)
      .to receive(:get_teaching_subjects).and_return(teaching_subjects)
  end

  describe ".api_subject_from_gitis_uuid" do
    it "returns subject name" do
      name = subject.api_subject_from_gitis_uuid(subject_id)
      expect(name).to eq(subject_name)
    end
  end

  describe ".api_subject_id_from_gitis_value" do
    it "returns subject id" do
      id = subject.api_subject_id_from_gitis_value(subject_name)
      expect(id).to eq(subject_id)
    end
  end
end
