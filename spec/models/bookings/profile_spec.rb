require 'rails_helper'

RSpec.describe Bookings::Profile, type: :model do
  describe "relationships" do
    it { is_expected.to belong_to(:school).class_name("Bookings::School").required }
  end

  describe 'methods' do
    describe '#dress_code' do
      context 'omitting other details' do
        subject { create(:bookings_profile, dress_code_cover_tattoos: true, dress_code_other_details: 'any pants') }

        specify 'should not include the contents of dress_code_other_details' do
          expect(subject.dress_code).not_to include('pants')
        end
      end

      context 'correctly adding code flags' do
        subject { create(:bookings_profile, dress_code_cover_tattoos: true, dress_code_remove_piercings: true) }

        specify 'should contain the correct information' do
          %w[tattoos piercings].each do |dc|
            expect(subject.dress_code).to include(dc)
          end
        end

        specify 'should not include incorrect information' do
          expect(subject.dress_code).not_to match(/casual/i)
        end
      end

      context 'capitalising output' do
        subject { create(:bookings_profile, dress_code_smart_casual: true) }

        specify 'should not include incorrect information' do
          expect(subject.dress_code).to eql('Smart casual')
        end
      end
    end
  end

  describe "validations" do
    describe "bookings_school_id" do
      before { create(:bookings_profile) }
      it { is_expected.to validate_uniqueness_of :school_id }
    end

    describe "dbs_policy_conditions" do
      described_class::DBS_POLICY_CONDITIONS.each do |condition|
        it { is_expected.to allow_value(condition).for :dbs_policy_conditions }
      end
      it { is_expected.not_to allow_value("random").for :dbs_policy_conditions }
      it { is_expected.not_to allow_value("").for :dbs_policy_conditions }
      it { is_expected.not_to allow_value(nil).for :dbs_policy_conditions }
    end

    describe "dbs_policy_details" do
      context 'when dbs_policy_conditions is required' do
        before { subject.dbs_policy_conditions = 'required' }
        it { is_expected.to validate_presence_of :dbs_policy_details }
      end

      context 'when dbs_policy_conditions is inschool' do
        before { subject.dbs_policy_conditions = 'inschool' }
        it { is_expected.to validate_presence_of :dbs_policy_details }
      end

      context 'when dbs_policy_conditions is notrequired' do
        before { subject.dbs_policy_conditions = 'notrequired' }
        it { is_expected.not_to validate_presence_of :dbs_policy_details }
      end
    end

    describe "individual_requirements" do
      it { is_expected.to allow_value(nil).for :individual_requirements }
      it { is_expected.to allow_value("something").for :individual_requirements }
      it { is_expected.not_to allow_value("").for :individual_requirements }
    end

    describe "phases" do
      it { is_expected.to allow_value(true).for :primary_phase }
      it { is_expected.to allow_value(false).for :primary_phase }
      it { is_expected.not_to allow_value(nil).for :primary_phase }

      it { is_expected.to allow_value(true).for :secondary_phase }
      it { is_expected.to allow_value(false).for :secondary_phase }
      it { is_expected.not_to allow_value(nil).for :secondary_phase }

      it { is_expected.to allow_value(true).for :college_phase }
      it { is_expected.to allow_value(false).for :college_phase }
      it { is_expected.not_to allow_value(nil).for :college_phase }

      context 'with none selected' do
        subject do
          build(:bookings_profile,
            primary_phase: false,
            secondary_phase: false,
            college_phase: false)
        end

        it { expect(subject.valid?).to be false }
      end
    end

    describe "key stages" do
      context "with primary_phase enabled" do
        subject do
          build(:bookings_profile,
            key_stage_early_years: false,
            key_stage_1: false,
            key_stage_2: false)
        end

        context 'with no key stage' do
          it { expect(subject.valid?).to be false }
        end

        context 'with key_stage_early_years' do
          before { subject.key_stage_early_years = true }
          it { expect(subject.valid?).to be true }
        end

        context 'with key_stage_1' do
          before { subject.key_stage_1 = true }
          it { expect(subject.valid?).to be true }
        end

        context 'with key_stage_2' do
          before { subject.key_stage_2 = true }
          it { expect(subject.valid?).to be true }
        end

        context 'with multiple key stages' do
          before do
            subject.key_stage_early_years = true
            subject.key_stage_1 = true
          end
          it { expect(subject.valid?).to be true }
        end
      end

      context "with primary_phase disabled" do
        subject do
          build(:bookings_profile,
            primary_phase: false,
            secondary_phase: true,
            key_stage_2: false)
        end
        it { expect(subject.valid?).to be true }
      end
    end

    describe "description_details" do
      it { is_expected.to allow_value(nil).for(:description_details) }
      it { is_expected.to allow_value('x').for(:description_details) }
      it { is_expected.to allow_value('').for(:description_details) }
    end

    describe "dress_code" do
      it { is_expected.to allow_value(true).for :dress_code_business }
      it { is_expected.to allow_value(false).for :dress_code_business }
      it { is_expected.not_to allow_value(nil).for :dress_code_business }

      it { is_expected.to allow_value(true).for :dress_code_cover_tattoos }
      it { is_expected.to allow_value(false).for :dress_code_cover_tattoos }
      it { is_expected.not_to allow_value(nil).for :dress_code_cover_tattoos }

      it { is_expected.to allow_value(true).for :dress_code_remove_piercings }
      it { is_expected.to allow_value(false).for :dress_code_remove_piercings }
      it { is_expected.not_to allow_value(nil).for :dress_code_remove_piercings }

      it { is_expected.to allow_value(true).for :dress_code_smart_casual }
      it { is_expected.to allow_value(false).for :dress_code_smart_casual }
      it { is_expected.not_to allow_value(nil).for :dress_code_smart_casual }

      it { is_expected.to allow_value(nil).for(:dress_code_other_details) }
      it { is_expected.to allow_value('x').for(:dress_code_other_details) }
      it { is_expected.not_to allow_value('').for(:dress_code_other_details) }
    end

    describe "parking" do
      it { is_expected.to allow_value(true).for :parking_provided }
      it { is_expected.to allow_value(false).for :parking_provided }
      it { is_expected.not_to allow_value(nil).for :parking_provided }

      it { is_expected.to validate_presence_of(:parking_details) }
    end

    describe "disabled_facilities" do
      it { is_expected.to allow_value(nil).for(:disabled_facilities) }
      it { is_expected.to allow_value('x').for(:disabled_facilities) }
      it { is_expected.not_to allow_value('').for(:disabled_facilities) }
    end

    describe "start_time" do
      it { is_expected.to validate_presence_of(:start_time) }
      it { is_expected.to allow_value('12:00').for(:start_time) }
      it { is_expected.to allow_value('17:00').for(:start_time) }
      it { is_expected.to allow_value('9:00').for(:start_time) }
      it { is_expected.to allow_value('09:00').for(:start_time) }
      it { is_expected.to allow_value(' 9:00 ').for(:start_time) }
      it { is_expected.to allow_value('9:00am').for(:start_time) }
      it { is_expected.to allow_value('09:00am').for(:start_time) }
      it { is_expected.to allow_value('11:15pm').for(:start_time) }
      it { is_expected.to allow_value('12:15am').for(:start_time) }
      it { is_expected.to allow_value('12:15pm').for(:start_time) }
    end

    describe "end_time" do
      it { is_expected.to validate_presence_of(:end_time) }
      it { is_expected.to allow_value('12:00').for(:end_time) }
      it { is_expected.to allow_value('17:00').for(:end_time) }
      it { is_expected.to allow_value('9:00').for(:end_time) }
      it { is_expected.to allow_value('09:00').for(:end_time) }
      it { is_expected.to allow_value(' 9:00 ').for(:end_time) }
      it { is_expected.to allow_value('9:00am').for(:end_time) }
      it { is_expected.to allow_value('09:00am').for(:end_time) }
      it { is_expected.to allow_value('11:15pm').for(:end_time) }
      it { is_expected.to allow_value('12:15am').for(:end_time) }
      it { is_expected.to allow_value('12:15pm').for(:end_time) }
    end

    describe "flexible_on_times" do
      it { is_expected.to allow_value(true).for(:flexible_on_times) }
      it { is_expected.to allow_value(false).for(:flexible_on_times) }
      it { is_expected.not_to allow_value(nil).for(:flexible_on_times) }
    end

    describe "flexible_on_times_details" do
      context 'when flexible_on_times' do
        subject { described_class.new flexible_on_times: true }

        it { is_expected.to validate_presence_of(:flexible_on_times_details) }
      end

      context 'when not flexible_on_times' do
        it { is_expected.not_to validate_presence_of(:flexible_on_times_details) }
      end
    end

    describe "teacher_training_info" do
      it { is_expected.to allow_value(nil).for(:teacher_training_info) }
      it { is_expected.to allow_value('').for(:teacher_training_info) }
      it { is_expected.to allow_value('x').for(:teacher_training_info) }
    end

    describe "teacher_training_url" do
      context "with blank teacher_training_info" do
        it { is_expected.to allow_value('').for(:teacher_training_url) }
      end

      context 'with assigned teacher_training_info' do
        subject { described_class.new(teacher_training_info: 'hello world') }
        it { is_expected.to allow_value('').for(:teacher_training_url) }
        it { is_expected.to allow_value('https://test.com').for(:teacher_training_url) }
        it { is_expected.to allow_value('http://test.com').for(:teacher_training_url) }
        it { is_expected.not_to allow_value('test.com').for(:teacher_training_url) }
      end
    end

    describe "admin_contact_email" do
      it { is_expected.to allow_value('me@you.com').for :admin_contact_email }
      it { is_expected.to allow_value('me.test@you.co.uk').for :admin_contact_email }
      it { is_expected.not_to allow_value('you.com').for :admin_contact_email }
      it { is_expected.not_to allow_value('https://you.com').for :admin_contact_email }
      it { is_expected.not_to allow_value('me@you').for :admin_contact_email }
      it { is_expected.not_to allow_value('').for :admin_contact_email }
    end

    describe "admin_contact_email_secondary" do
      it { is_expected.to allow_value('me@you.com').for :admin_contact_email_secondary }
      it { is_expected.to allow_value('me.test@you.co.uk').for :admin_contact_email_secondary }
      it { is_expected.not_to allow_value('you.com').for :admin_contact_email_secondary }
      it { is_expected.not_to allow_value('https://you.com').for :admin_contact_email_secondary }
      it { is_expected.not_to allow_value('me@you').for :admin_contact_email_secondary }
      it { is_expected.not_to allow_value('').for :admin_contact_email_secondary }
      it { is_expected.to allow_value(nil).for :admin_contact_email_secondary }
    end

    describe "admin_contact_phone" do
      it { is_expected.to allow_value('07123456789').for :admin_contact_phone }
      it { is_expected.to allow_value('02019123456').for :admin_contact_phone }
      it { is_expected.to allow_value('01909123456').for :admin_contact_phone }
      it { is_expected.not_to allow_value('020991234').for :admin_contact_phone }
      it { is_expected.not_to allow_value('foobar').for :admin_contact_phone }
      it { is_expected.not_to allow_value('').for :admin_contact_phone }
      it { is_expected.not_to allow_value(nil).for :admin_contact_phone }
    end

    describe "administration_fee_amount_pounds" do
      it { is_expected.to allow_value(10.00).for(:administration_fee_amount_pounds) }
      it { is_expected.to allow_value(1).for(:administration_fee_amount_pounds) }
      it { is_expected.not_to allow_value(0.00).for(:administration_fee_amount_pounds) }
      it { is_expected.to allow_value(nil).for(:administration_fee_amount_pounds) }
    end

    describe "administration_fee_description" do
      context "with amount_pounds set" do
        subject { described_class.new(administration_fee_amount_pounds: 10.00) }
        it { is_expected.to validate_presence_of :administration_fee_description }
      end

      context "with amount_pounds unset" do
        it { is_expected.not_to validate_presence_of :administration_fee_description }
      end
    end

    describe "administration_fee_interval" do
      context "with amount_pounds set" do
        subject { described_class.new(administration_fee_amount_pounds: 10.00) }
        described_class::AVAILABLE_INTERVALS.each do |interval|
          it { is_expected.to allow_value(interval).for :administration_fee_interval }
        end
        it { is_expected.not_to allow_value('random').for :administration_fee_interval }
      end

      context "with amount_pounds unset" do
        it { is_expected.not_to validate_presence_of :administration_fee_interval }
      end
    end

    describe "administration_fee_payment_method" do
      context "with amount_pounds set" do
        subject { described_class.new(administration_fee_amount_pounds: 10.00) }
        it { is_expected.to validate_presence_of :administration_fee_payment_method }
      end

      context "with amount_pounds unset" do
        it { is_expected.not_to validate_presence_of :administration_fee_payment_method }
      end
    end

    describe "dbs_fee_amount_pounds" do
      it { is_expected.to allow_value(10.00).for(:dbs_fee_amount_pounds) }
      it { is_expected.to allow_value(1).for(:dbs_fee_amount_pounds) }
      it { is_expected.not_to allow_value(0.00).for(:dbs_fee_amount_pounds) }
      it { is_expected.to allow_value(nil).for(:dbs_fee_amount_pounds) }
    end

    describe "dbs_fee_description" do
      context "with amount_pounds set" do
        subject { described_class.new(dbs_fee_amount_pounds: 10.00) }
        it { is_expected.to validate_presence_of :dbs_fee_description }
      end

      context "with amount_pounds unset" do
        it { is_expected.not_to validate_presence_of :dbs_fee_description }
      end
    end

    describe "dbs_fee_interval" do
      context "with amount_pounds set" do
        subject { described_class.new(dbs_fee_amount_pounds: 10.00) }
        described_class::AVAILABLE_INTERVALS.each do |interval|
          it { is_expected.to allow_value(interval).for :dbs_fee_interval }
        end
        it { is_expected.not_to allow_value('random').for :dbs_fee_interval }
      end

      context "with amount_pounds unset" do
        it { is_expected.not_to validate_presence_of :dbs_fee_interval }
      end
    end

    describe "dbs_fee_payment_method" do
      context "with amount_pounds set" do
        subject { described_class.new(dbs_fee_amount_pounds: 10.00) }
        it { is_expected.to validate_presence_of :dbs_fee_payment_method }
      end

      context "with amount_pounds unset" do
        it { is_expected.not_to validate_presence_of :dbs_fee_payment_method }
      end
    end

    describe "other_fee_amount_pounds" do
      it { is_expected.to allow_value(10.00).for(:other_fee_amount_pounds) }
      it { is_expected.to allow_value(1).for(:other_fee_amount_pounds) }
      it { is_expected.not_to allow_value(0.00).for(:other_fee_amount_pounds) }
      it { is_expected.to allow_value(nil).for(:other_fee_amount_pounds) }
    end

    describe "other_fee_description" do
      context "with amount_pounds set" do
        subject { described_class.new(other_fee_amount_pounds: 10.00) }
        it { is_expected.to validate_presence_of :other_fee_description }
      end

      context "with amount_pounds unset" do
        it { is_expected.not_to validate_presence_of :other_fee_description }
      end
    end

    describe "other_fee_interval" do
      context "with amount_pounds set" do
        subject { described_class.new(other_fee_amount_pounds: 10.00) }
        described_class::AVAILABLE_INTERVALS.each do |interval|
          it { is_expected.to allow_value(interval).for :other_fee_interval }
        end
        it { is_expected.not_to allow_value('random').for :other_fee_interval }
      end

      context "with amount_pounds unset" do
        it { is_expected.not_to validate_presence_of :other_fee_interval }
      end
    end

    describe "other_fee_payment_method" do
      context "with amount_pounds set" do
        subject { described_class.new(other_fee_amount_pounds: 10.00) }
        it { is_expected.to validate_presence_of :other_fee_payment_method }
      end

      context "with amount_pounds unset" do
        it { is_expected.not_to validate_presence_of :other_fee_payment_method }
      end
    end

    describe "access_needs" do
      context 'with supports_access_needs' do
        subject { create :bookings_profile }

        it { is_expected.not_to allow_value(nil).for :supports_access_needs }
        it { is_expected.to validate_presence_of :access_needs_description }
        it { is_expected.not_to allow_value(nil).for :disability_confident }
        it { is_expected.not_to allow_value(nil).for :has_access_needs_policy }

        context 'with has_access_needs_policy' do
          before { subject.has_access_needs_policy = true }
          it { is_expected.to validate_presence_of :access_needs_policy_url }
        end

        context 'without has_access_needs_policy' do
          before { subject.has_access_needs_policy = false }
          it { is_expected.not_to validate_presence_of :access_needs_policy_url }
        end
      end

      context 'without access_needs_support' do
        subject { create :bookings_profile, :without_supports_access_needs }

        it { is_expected.not_to allow_value(nil).for :supports_access_needs }
        it { is_expected.not_to validate_presence_of :access_needs_description }
        it { is_expected.to allow_value(nil).for :disability_confident }
        it { is_expected.to allow_value(nil).for :has_access_needs_policy }
      end
    end

    describe "#has_fees?" do
      context "when there are fees" do
        subject { build(:bookings_profile, :with_admin_fee) }

        it { is_expected.to be_has_fees }
      end

      context "when there are not any fees" do
        subject { build(:bookings_profile) }

        it { is_expected.not_to be_has_fees }
      end
    end
  end
end
