require 'rails_helper'

shared_examples "invalid requests" do
  context "when the token is incorrect" do
    let(:token) { "incorrect" }

    it { expect { perform_request }.to raise_error(ActiveRecord::RecordNotFound) }
  end

  context "when there is no booking" do
    let(:placement_request) { create(:placement_request) }

    it { is_expected.to render_template(:booking_not_attended) }
  end

  context "when the booking has not yet been attended" do
    let(:placement_request) { create(:placement_request, :with_incomplete_booking) }

    it { is_expected.to render_template(:booking_not_attended) }
  end

  context "when feedback has already been left" do
    before { create(:candidates_booking_feedback, booking: booking) }

    it { is_expected.to render_template(:feedback_already_provided) }
  end
end

describe Candidates::BookingFeedbacksController, type: :request do
  let(:placement_request) { create(:placement_request, :with_attended_booking) }
  let(:booking) { placement_request.booking }
  let(:token) { placement_request.token }

  describe "#new" do
    include_context "invalid requests"

    subject(:perform_request) do
      get new_candidates_booking_feedback_path(token)
      response
    end

    it { is_expected.to render_template(:new) }
  end

  describe "#create" do
    include_context "invalid requests"

    let(:attributes) { attributes_for(:candidates_booking_feedback) }
    let(:params) { { candidates_booking_feedback: attributes } }
    let(:created_feedback) { Candidates::BookingFeedback.last }

    subject(:perform_request) do
      post candidates_booking_feedback_path(token, params: params)
      response
    end

    it { is_expected.to redirect_to(created_feedback) }
    it { expect { perform_request }.to change { Candidates::BookingFeedback.count }.by(1) }

    it "creates feedback associated to the booking" do
      perform_request
      expect(created_feedback).to have_attributes(attributes.merge(booking: booking))
    end

    context "when the request is invalid" do
      before { attributes[:gave_realistic_impression] = nil }

      it { is_expected.to render_template(:new) }
    end
  end

  describe "#show" do
    subject do
      get candidates_booking_feedback_path(token)
      response
    end

    it { is_expected.to render_template(:show) }
  end
end
