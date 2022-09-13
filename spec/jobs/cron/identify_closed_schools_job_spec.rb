require "rails_helper"

describe Cron::IdentifyClosedSchoolsJob, type: :job do
  describe "#perform" do
    let(:email_double) { instance_double(NotifyEmail::ClosedOnboardedSchoolsSummary, despatch_later!: nil) }
    let(:closed_school_1) { create(:bookings_school, :onboarded) }
    let(:closed_school_2) { create(:bookings_school, :onboarded) }
    let(:closed_school_3) { create(:bookings_school, :onboarded) }
    let(:reopened_school_1) { create(:bookings_school) }
    let(:reopened_school_2) { create(:bookings_school) }
    let(:csv) do
      <<~CSV
        URN,CloseDate,LA (code),EstablishmentNumber,LA (name)
        #{closed_school_1.urn},#{1.month.ago},888,1572,Hillend Primary
        #{closed_school_2.urn},#{1.day.ago},888,1572,Hillend Primary
        #{reopened_school_1.urn},,888,1572,Hillend Primary
        #{reopened_school_2.urn},,888,1572,Hillend Primary
        #{closed_school_3.urn},#{2.days.ago},999,1984,Main St Secondary
      CSV
    end

    subject(:perform) { described_class.new.perform }

    before do
      temp_csv = Tempfile.new
      temp_csv.write(csv)
      temp_csv.close
      allow_any_instance_of(Bookings::Data::GiasDataFile).to receive(:path) { temp_csv.path }
      allow(Rails).to receive(:env) { "production".inquiry }
    end

    it "emails the service inbox with closed, on-boarded school details" do
      closed_text = "#{closed_school_1.name} is enabled (URN #{closed_school_1.urn}, replacement URN(s) #{reopened_school_1.urn} and #{reopened_school_2.urn}). "\
      "#{closed_school_2.name} is enabled (URN #{closed_school_2.urn}, replacement URN(s) #{reopened_school_1.urn} and #{reopened_school_2.urn}). "\
      "#{closed_school_3.name} is enabled (URN #{closed_school_3.urn})."

      params = {
        to: described_class::SERVICE_INBOX,
        closed_onboarded_schools: closed_text
      }
      allow(NotifyEmail::ClosedOnboardedSchoolsSummary).to receive(:new).with(params) { email_double }
      perform
      expect(email_double).to have_received(:despatch_later!)
    end

    context "when there are no closed, on-boarded schools" do
      let(:csv) { "" }

      it "emails the service inbox" do
        params = {
          to: described_class::SERVICE_INBOX,
          closed_onboarded_schools: "There are no closed, on-boarded schools."
        }
        allow(NotifyEmail::ClosedOnboardedSchoolsSummary).to receive(:new).with(params) { email_double }
        perform
        expect(email_double).to have_received(:despatch_later!)
      end
    end

    context "when not running in production" do
      before { allow(Rails).to receive(:env) { "preprod".inquiry } }

      it "does not send any emails" do
        expect(NotifyEmail::ClosedOnboardedSchoolsSummary).not_to receive(:new)
      end
    end
  end
end
