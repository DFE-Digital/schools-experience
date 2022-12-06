require "rails_helper"

describe Schools::OnBoardingHelper, type: :helper do
  describe "#task_row" do
    subject { task_row("Task", "/task", :not_started) }

    it { is_expected.to have_css(".govuk-summary-list__row .govuk-summary-list__key") }
    it { is_expected.to have_css(".govuk-summary-list__row .govuk-summary-list__actions") }
    it { is_expected.to have_css(".govuk-summary-list__key a[href='/task']", text: "Task") }
    it { is_expected.to have_css(".govuk-summary-list__actions strong.govuk-tag.govuk-tag--grey", text: "Not started") }
  end

  describe "#task_link" do
    subject { task_link("Task", "/task", status) }

    context "when not_started" do
      let(:status) { :not_started }

      it { is_expected.to have_css("a[href='/task']", text: "Task") }
    end

    context "when not_applicable" do
      let(:status) { :not_applicable }

      it { is_expected.to have_css("span", text: "Task") }
    end

    context "when cannot_start_yet" do
      let(:status) { :cannot_start_yet }

      it { is_expected.to have_css("span", text: "Task") }
    end

    context "when complete" do
      let(:status) { :complete }

      it { is_expected.to have_css("a[href='/task']", text: "Task") }
    end
  end

  describe "#task_tag" do
    subject { task_tag(status) }

    context "when not_started" do
      let(:status) { :not_started }

      it { is_expected.to have_css("strong.govuk-tag.govuk-tag--grey", text: "Not started") }
    end

    context "when not_applicable" do
      let(:status) { :not_applicable }

      it { is_expected.to have_css("strong.govuk-tag.govuk-tag--grey", text: "Not applicable") }
    end

    context "when cannot_start_yet" do
      let(:status) { :cannot_start_yet }

      it { is_expected.to be_nil }
    end

    context "when complete" do
      let(:status) { :complete }

      it { is_expected.to have_css("strong.govuk-tag.govuk-tag--green", text: "Complete") }
    end
  end
end
