require "rails_helper"

describe Cron::IdentifyClosedSchoolsJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    let(:email_double) { instance_double(NotifyEmail::ClosedOnboardedSchoolsSummary, despatch_later!: nil) }
    let(:enabled_school_closed_last_month) { create(:bookings_school, :onboarded) }
    let(:enabled_school_closed_yesterday) { create(:bookings_school, :onboarded) }
    let(:disabled_school_closed_two_days_ago) { create(:bookings_school, :onboarded, :disabled) }
    let(:disabled_school_closed_five_days_ago) { create(:bookings_school, :onboarded, :disabled) }
    let(:enabled_school_closed_twelve_days_ago) { create(:bookings_school, :onboarded) }
    let(:replacement_school_hillend_one) { create(:bookings_school) }
    let(:replacement_school_hillend_two) { create(:bookings_school) }
    let(:replacement_school_st_anne) { create(:bookings_school) }
    let(:csv) do
      <<~CSV
        URN,CloseDate,LA (code),EstablishmentNumber,LA (name)
        #{enabled_school_closed_last_month.urn},#{1.month.ago},888,1572,Hillend Primary
        #{enabled_school_closed_yesterday.urn},#{1.day.ago},888,1572,Hillend Primary
        #{replacement_school_hillend_one.urn},,888,1572,Hillend Primary
        #{replacement_school_hillend_two.urn},,888,1572,Hillend Primary
        #{disabled_school_closed_two_days_ago.urn},#{2.days.ago},999,1984,Main St Secondary
        #{disabled_school_closed_five_days_ago.urn},#{5.days.ago},777,1847,St Anne Primary
        #{replacement_school_st_anne.urn},,777,1847,St Anne Primary
        #{enabled_school_closed_twelve_days_ago.urn},#{12.days.ago},444,1746,St James Primary
      CSV
    end

    before do
      temp_csv = Tempfile.new
      temp_csv.write(csv)
      temp_csv.close
      data_file = instance_double(Bookings::Data::GiasDataFile, path: temp_csv.path)
      allow(Bookings::Data::GiasDataFile).to receive(:new).and_return(data_file)
      allow(Rails).to receive(:env) { "production".inquiry }
    end

    it "emails the service inbox with closed, on-boarded school details" do
      closed_text = <<~MARKDOWN.chomp
        ## Schools that are disabled without replacements

        * #{disabled_school_closed_two_days_ago.name} (URN #{disabled_school_closed_two_days_ago.urn}).

        ## Schools that are disabled with replacements

        * #{disabled_school_closed_five_days_ago.name} (URN #{disabled_school_closed_five_days_ago.urn}, replacement URN(s) #{replacement_school_st_anne.urn}).

        ## Schools that are enabled without replacements

        * #{enabled_school_closed_twelve_days_ago.name} (URN #{enabled_school_closed_twelve_days_ago.urn}).

        ## Schools that are enabled with replacements

        * #{enabled_school_closed_last_month.name} (URN #{enabled_school_closed_last_month.urn}, replacement URN(s) #{replacement_school_hillend_one.urn} and #{replacement_school_hillend_two.urn}).
        * #{enabled_school_closed_yesterday.name} (URN #{enabled_school_closed_yesterday.urn}, replacement URN(s) #{replacement_school_hillend_one.urn} and #{replacement_school_hillend_two.urn}).
      MARKDOWN

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
        allow(NotifyEmail::ClosedOnboardedSchoolsSummary).to receive(:new)
        perform
        expect(NotifyEmail::ClosedOnboardedSchoolsSummary).not_to have_received(:new)
      end
    end
  end
end
