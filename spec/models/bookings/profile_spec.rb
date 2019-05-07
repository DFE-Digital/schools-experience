require 'rails_helper'

RSpec.describe Bookings::Profile, type: :model do
  describe "relationships" do
    it { is_expected.to belong_to(:school).class_name("Bookings::School").required }
  end

  describe "validations" do
    describe "bookings_school_id" do
      before { create(:bookings_profile) }
      it { is_expected.to validate_uniqueness_of :school_id }
    end

    describe "dbs" do
      it { is_expected.to validate_presence_of :dbs_required }
      described_class::DBS_REQUIREMENTS.each do |req|
        it { is_expected.to allow_value(req).for :dbs_required }
      end
      it { is_expected.not_to allow_value(10).for :dbs_required }

      context "when dbs_policy required" do
        subject { described_class.new(dbs_required: 'sometimes') }
        it { is_expected.to allow_value("something").for :dbs_policy }
        it { is_expected.not_to allow_value("").for :dbs_policy }
        it { is_expected.not_to allow_value(nil).for :dbs_policy }
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
      it { is_expected.not_to allow_value('').for(:description_details) }
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

    describe "experience_details" do
      it { is_expected.to validate_presence_of(:experience_details) }
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
        it { is_expected.not_to allow_value('').for(:teacher_training_url) }
        it { is_expected.to allow_value('https://test.com').for(:teacher_training_url) }
        it { is_expected.to allow_value('http://test.com').for(:teacher_training_url) }
        it { is_expected.not_to allow_value('test.com').for(:teacher_training_url) }
      end
    end

    describe "admin_contact_full_name" do
      it { is_expected.to validate_presence_of :admin_contact_full_name }
    end

    describe "admin_contact_email" do
      it { is_expected.to allow_value('me@you.com').for :admin_contact_email }
      it { is_expected.to allow_value('me.test@you.co.uk').for :admin_contact_email }
      it { is_expected.not_to allow_value('you.com').for :admin_contact_email }
      it { is_expected.not_to allow_value('https://you.com').for :admin_contact_email }
      it { is_expected.not_to allow_value('me@you').for :admin_contact_email }
      it { is_expected.not_to allow_value('').for :admin_contact_email }
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

    describe "fixed_availibility" do
      it { is_expected.to allow_value(true).for(:fixed_availability) }
      it { is_expected.to allow_value(false).for(:fixed_availability) }
      it { is_expected.not_to allow_value(nil).for(:fixed_availability) }
    end

    describe "availibility_info" do
      context "for fixed_availibility" do
        subject { described_class.new(fixed_availability: true) }
        it { is_expected.not_to validate_presence_of :availability_info }
      end

      context "for flexible availibility" do
        subject { described_class.new(fixed_availability: false) }
        it { is_expected.to validate_presence_of :availability_info }
      end
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
  end
end
