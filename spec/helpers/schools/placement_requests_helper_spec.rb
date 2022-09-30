require "rails_helper"

describe Schools::PlacementRequestsHelper, type: :helper do
  describe "#cancellation_reasons" do
    let(:cancellation) do
      build(:cancellation,
        fully_booked: true,
        other: true,
        reason: "Sorry!")
    end

    subject { cancellation_reasons(cancellation) }

    it { is_expected.to have_css("ul li", count: 2) }
    it { is_expected.to have_css("li", text: "The date you requested is fully booked.") }
    it { is_expected.to have_css("li", text: "Sorry!") }

    context "when there is only a reason" do
      let(:cancellation) { build(:cancellation, reason: "Sorry!") }

      it { is_expected.to have_css("li", count: 1) }
      it { is_expected.to have_css("li", text: "Sorry!") }
    end

    context "when there are only categories selected" do
      let(:cancellation) { build(:cancellation, fully_booked: true, reason: nil) }

      it { is_expected.to have_css("li", count: 1) }
      it { is_expected.to have_css("li", text: "The date you requested is fully booked.") }
    end
  end
end
