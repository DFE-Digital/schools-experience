require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::CsvExportsController, type: :request do
  include_context "logged in DfE user for school with profile"

  subject { page_request && response }

  describe "#show" do
    let(:page_request) { get schools_csv_export_path }

    it { is_expected.to have_http_status :success }
    it { is_expected.to render_template "show" }
    it { is_expected.to render_template "_form" }
  end

  describe "#create" do
    let(:page_request) { post schools_csv_export_path, params: params }
    let(:filename) { "School experience export (#{school.urn}) - #{today}.csv" }
    let(:today) { Time.zone.today.to_formatted_s :govuk }
    let(:disposition) { subject.headers["Content-Disposition"] }

    context "when a date rage is provided" do
      let(:params) do
        { schools_csv_export_form: { from_date: Date.yesterday, to_date: Date.today } }
      end

      it { is_expected.to have_http_status :success }
      it { is_expected.to have_attributes media_type: "text/csv" }
      it { expect(disposition).to eql "attachment; filename=\"#{filename}\"" }
    end

    context "when date rage is not provided" do
      let(:params) do
        { schools_csv_export_form: { from_date: nil, to_date: nil } }
      end

      it { is_expected.to render_template "_form" }
    end
  end
end
