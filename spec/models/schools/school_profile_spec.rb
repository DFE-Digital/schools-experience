require 'rails_helper'

describe Schools::SchoolProfile, type: :model do
  context 'attributes' do
    it do
      is_expected.to have_db_column(:bookings_school_id).of_type :integer
    end

    it do
      is_expected.to \
        have_db_column(:dbs_requirement_requires_check).of_type :boolean
    end

    it do
      is_expected.to \
        have_db_column(:dbs_requirement_dbs_policy_details).of_type :text
    end

    it do
      is_expected.to \
        have_db_column(:dbs_requirement_no_dbs_policy_details).of_type :text
    end

    it do
      is_expected.to \
        have_db_column(:candidate_requirement_dbs_requirement).of_type :string
    end

    it do
      is_expected.to \
        have_db_column(:candidate_requirement_dbs_policy).of_type :text
    end

    it do
      is_expected.to \
        have_db_column(:candidate_requirement_requirements).of_type :boolean
    end

    it do
      is_expected.to \
        have_db_column(:candidate_requirement_requirements_details).of_type :text
    end

    it do
      is_expected.to \
        have_db_column(:fees_administration_fees).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:fees_dbs_fees).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:fees_other_fees).of_type :boolean
    end

    %w(administration_fee dbs_fee other_fee).each do |fee|
      it do
        is_expected.to \
          have_db_column(:"#{fee}_amount_pounds")
            .of_type(:decimal).with_options(precision: 6, scale: 2)
      end

      it do
        is_expected.to have_db_column(:"#{fee}_description").of_type :text
      end

      it do
        is_expected.to have_db_column(:"#{fee}_interval").of_type :string
      end

      it do
        is_expected.to have_db_column(:"#{fee}_payment_method").of_type :text
      end
    end

    it do
      is_expected.to have_db_column(:phases_list_primary).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:phases_list_secondary).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:phases_list_college).of_type :boolean
    end

    it do
      is_expected.to \
        have_db_column(:phases_list_secondary_and_college).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:description_details).of_type :text
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_business_dress).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_cover_up_tattoos).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_remove_piercings).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_smart_casual).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_other_dress_requirements).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_other_dress_requirements_detail).of_type :string
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_parking_provided).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_parking_details).of_type :string
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_nearby_parking_details).of_type :string
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_disabled_facilities).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_disabled_facilities_details).of_type :string
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_start_time).of_type :string
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_end_time).of_type :string
    end

    it do
      is_expected.to have_db_column(:candidate_experience_detail_times_flexible).of_type :boolean
    end

    it do
      is_expected.to \
        have_db_column(:candidate_experience_detail_times_flexible_details).of_type :text
    end

    it do
      is_expected.to \
        have_db_column(:experience_outline_candidate_experience).of_type :text
    end

    it do
      is_expected.to \
        have_db_column(:experience_outline_provides_teacher_training).of_type :boolean
    end

    it do
      is_expected.to \
        have_db_column(:experience_outline_teacher_training_details).of_type :text
    end

    it do
      is_expected.to \
        have_db_column(:experience_outline_teacher_training_url).of_type :string
    end

    it do
      is_expected.to have_db_column(:admin_contact_full_name).of_type :string
    end

    it do
      is_expected.to have_db_column(:admin_contact_email).of_type :string
    end

    it do
      is_expected.to have_db_column(:admin_contact_email_secondary).of_type :string
    end

    it do
      is_expected.to \
        have_db_column(:confirmation_acceptance).of_type(:boolean)
    end

    it do
      is_expected.to \
        have_db_column(:show_candidate_requirements_selection).of_type(:boolean)
    end

    it do
      is_expected.to \
        have_db_column(:candidate_requirements_choice_has_requirements).of_type(:boolean)
    end

    it do
      is_expected.to \
        have_db_column(:candidate_requirements_selection_step_completed)
          .of_type(:boolean).with_options(default: false)
    end

    it do
      is_expected.to \
        have_db_column(:access_needs_detail_description).of_type(:string)
    end

    it do
      is_expected.to \
        have_db_column(:disability_confident_is_disability_confident).of_type(:boolean)
    end

    it do
      is_expected.to \
        have_db_column(:access_needs_policy_has_access_needs_policy).of_type(:boolean)
    end

    it do
      is_expected.to have_db_column(:access_needs_policy_url).of_type(:string)
    end
  end

  context 'relationships' do
    it { is_expected.to have_many(:profile_subjects) }
    it { is_expected.to have_many(:subjects) }
    it { is_expected.to belong_to(:bookings_school) }
  end

  context 'delegation' do
    it { is_expected.to delegate_method(:urn).to(:bookings_school) }
  end

  context 'validations' do
    it do
      is_expected.to validate_presence_of :bookings_school
    end
  end

  context 'associations' do
    context 'subjects' do
      let(:bookings_school) { create(:bookings_school) }
      subject { described_class.create!(bookings_school: bookings_school) }

      let :bookings_subject do
        FactoryBot.create :bookings_subject
      end

      before do
        subject.subjects << bookings_subject
      end

      context '#subjects' do
        it 'only returns subjects' do
          expect(subject.subjects.to_a).to eq [bookings_subject]
        end
      end
    end
  end

  context 'values from form models' do
    let(:bookings_school) { create(:bookings_school) }
    let :model do
      described_class.new bookings_school: bookings_school
    end

    context '#dbs_requirement' do
      let :form_model do
        FactoryBot.build :dbs_requirement
      end

      before do
        model.dbs_requirement = form_model
      end

      {
        dbs_requirement_requires_check: :requires_check,
        dbs_requirement_dbs_policy_details: :dbs_policy_details,
        dbs_requirement_no_dbs_policy_details: :no_dbs_policy_details
      }.each_pair do |column, model_attribute|
        it "is expected to map #{column} to #{model_attribute}" do
          expect(model.send(column)).to eq form_model.send(model_attribute)
        end
      end

      it 'returns the form_model' do
        expect(model.dbs_requirement).to eq_model form_model
      end
    end

    context '#fees' do
      let :form_model do
        FactoryBot.build :fees
      end

      before do
        model.fees = form_model
      end

      it 'sets fees_administration_fees' do
        expect(model.fees_administration_fees).to eq \
          form_model.administration_fees
      end

      it 'sets fees_dbs_fees' do
        expect(model.fees_dbs_fees).to eq form_model.dbs_fees
      end

      it 'sets fees_other_fees' do
        expect(model.fees_other_fees).to eq form_model.other_fees
      end

      it 'returns the form model' do
        expect(model.fees).to eq form_model
      end
    end

    context 'school_fees' do
      %w(administration_fee dbs_fee other_fee).each do |fee|
        context fee do
          let :form_model do
            FactoryBot.build fee
          end

          before do
            model.public_send "#{fee}=", form_model
          end

          it "sets #{fee}_amount_pounds" do
            expect(model.public_send("#{fee}_amount_pounds")).to \
              eq form_model.amount_pounds
          end

          it "sets #{fee}_description" do
            expect(model.public_send("#{fee}_description")).to \
              eq form_model.description
          end

          it "sets #{fee}_interval" do
            expect(model.public_send("#{fee}_interval")).to eq \
              form_model.interval
          end

          it "sets #{fee}_payment_method" do
            expect(model.public_send("#{fee}_payment_method")).to \
              eq form_model.payment_method
          end

          it 'returns the form model' do
            expect(model.public_send(fee)).to eq form_model
          end
        end
      end
    end

    context '#phases_list' do
      let :form_model do
        FactoryBot.build :phases_list
      end

      before do
        model.phases_list = form_model
      end

      it 'sets phases_list_primary' do
        expect(model.phases_list_primary).to eq form_model.primary
      end

      it 'sets phases_list_secondary' do
        expect(model.phases_list_secondary).to eq form_model.secondary
      end

      it 'sets phases_list_college' do
        expect(model.phases_list_college).to eq form_model.college
      end

      it 'sets phases_list_secondary_and_college' do
        expect(model.phases_list_secondary_and_college).to \
          eq form_model.secondary_and_college
      end

      it 'returns the form model' do
        expect(model.phases_list).to eq form_model
      end
    end

    context '#key_stage_list' do
      let :form_model do
        FactoryBot.build :key_stage_list
      end

      before do
        model.key_stage_list = form_model
      end

      it 'sets early_years' do
        expect(model.key_stage_list.early_years).to eq form_model.early_years
      end

      it 'sets key_stage_1' do
        expect(model.key_stage_list.key_stage_1).to eq form_model.key_stage_1
      end

      it 'sets key_stage_2' do
        expect(model.key_stage_list.key_stage_2).to eq form_model.key_stage_2
      end
    end

    context '#description' do
      let :form_model do
        FactoryBot.build :description
      end

      before do
        model.description = form_model
      end

      it 'sets details' do
        expect(model.description_details).to eq form_model.details
      end

      it 'returns the form model' do
        expect(model.description).to eq form_model
      end
    end

    context '#candidate_experience_detail' do
      let :form_model do
        FactoryBot.build :candidate_experience_detail
      end

      before do
        model.candidate_experience_detail = form_model
      end

      %i(
        business_dress
        cover_up_tattoos
        remove_piercings
        smart_casual
        other_dress_requirements
        other_dress_requirements_detail
        parking_provided
        parking_details
        nearby_parking_details
        disabled_facilities
        disabled_facilities_details
        start_time
        end_time
        times_flexible
        times_flexible_details
      ).each do |attribute|
        it "sets #{attribute} correctly" do
          expect(model.send("candidate_experience_detail_#{attribute}")).to \
            eq form_model.send attribute
        end
      end

      it 'returns the form model' do
        expect(model.candidate_experience_detail).to eq form_model
      end
    end

    context '#access_needs_support' do
      let :form_model do
        FactoryBot.build :access_needs_support
      end

      before do
        model.access_needs_support = form_model
      end

      %i(supports_access_needs).each do |attribute|
        it "sets #{attribute} correctly" do
          expect(model.send("access_needs_support_#{attribute}")).to \
            eq form_model.send attribute
        end
      end

      it 'returns the form model' do
        expect(model.access_needs_support).to eq form_model
      end
    end

    context '#access_needs_detail' do
      let :form_model do
        FactoryBot.build :access_needs_detail
      end

      before do
        model.access_needs_detail = form_model
      end

      %i(description).each do |attribute|
        it "sets #{attribute} correctly" do
          expect(model.send("access_needs_detail_#{attribute}")).to \
            eq form_model.send attribute
        end
      end

      it 'returns the form model' do
        expect(model.access_needs_detail).to eq form_model
      end
    end

    context '#disability_confident' do
      let :form_model do
        FactoryBot.build :disability_confident
      end

      before do
        model.disability_confident = form_model
      end

      %i(is_disability_confident).each do |attribute|
        it "sets #{attribute} correctly" do
          expect(model.send("disability_confident_#{attribute}")).to \
            eq form_model.send attribute
        end
      end

      it 'returns the form model' do
        expect(model.disability_confident).to eq form_model
      end
    end

    context '#access_needs_policy' do
      let :form_model do
        FactoryBot.build :access_needs_policy
      end

      before do
        model.access_needs_policy = form_model
      end

      %i(has_access_needs_policy url).each do |attribute|
        it "sets #{attribute} correctly" do
          expect(model.send("access_needs_policy_#{attribute}")).to \
            eq form_model.send attribute
        end
      end

      it 'returns the form model' do
        expect(model.access_needs_policy).to eq form_model
      end
    end

    context '#experience_outline' do
      let :form_model do
        FactoryBot.build :experience_outline
      end

      before do
        model.experience_outline = form_model
      end

      %i(
        candidate_experience
        provides_teacher_training
        teacher_training_details
        teacher_training_url
      ).each do |attribute|
        it "sets #{attribute} correctly" do
          expect(model.send("experience_outline_#{attribute}")).to \
            eq form_model.send attribute
        end
      end

      it 'returns the form model' do
        expect(model.experience_outline).to eq form_model
      end
    end

    context '#admin_contact' do
      let :form_model do
        FactoryBot.build :admin_contact
      end

      before do
        model.admin_contact = form_model
      end

      %i(phone email email_secondary).each do |attribute|
        it "sets #{attribute} correctly" do
          expect(model.send("admin_contact_#{attribute}")).to \
            eq form_model.send attribute
        end
      end

      it 'returns the form model' do
        expect(model.admin_contact).to eq form_model
      end
    end

    context '#confirmation' do
      let :form_model do
        FactoryBot.build :confirmation
      end

      before do
        model.confirmation = form_model
      end

      it 'returns the form model' do
        expect(model.confirmation).to eq form_model
      end
    end
  end

  context 'callbacks' do
    context 'before_validation' do
      context 'when administration_fee no longer makes sense' do
        let :school_profile do
          FactoryBot.create \
            :school_profile, :with_fees, :with_administration_fee
        end

        before do
          school_profile.update! \
            fees: FactoryBot.build(:fees, administration_fees: false)
        end

        it 'resets administration_fee' do
          expect(school_profile.administration_fee).to \
            eq Schools::OnBoarding::AdministrationFee.new
        end
      end

      context 'when dbs_fee no longer makes sense' do
        let :school_profile do
          FactoryBot.create :school_profile, :with_fees, :with_dbs_fee
        end

        before do
          school_profile.update! fees: FactoryBot.build(:fees, dbs_fees: false)
        end

        it 'resets dbs_fee' do
          expect(school_profile.dbs_fee).to eq Schools::OnBoarding::DBSFee.new
        end
      end

      context 'when other_fee no longer makes sense' do
        let :school_profile do
          FactoryBot.create :school_profile, :with_fees, :with_other_fee
        end

        before do
          school_profile.update! \
            fees: FactoryBot.build(:fees, other_fees: false)
        end

        it 'resets other_fee' do
          expect(school_profile.other_fee).to \
            eq Schools::OnBoarding::OtherFee.new
        end
      end

      context 'when key_stage_list no longer makes sense' do
        let :school_profile do
          FactoryBot.create :school_profile, :with_phases, :with_key_stage_list
        end

        before do
          school_profile.update! \
            phases_list: Schools::OnBoarding::PhasesList.new(primary: false)
        end

        it 'resets key stage list' do
          expect(school_profile.reload.key_stage_list).to \
            eq Schools::OnBoarding::KeyStageList.new
        end
      end

      context 'when secondary_subjects no longer makes sense' do
        let :school_profile do
          FactoryBot.create :school_profile, :with_phases, :with_subjects
        end

        before do
          school_profile.update! \
            phases_list: Schools::OnBoarding::PhasesList.new(secondary: false)
        end

        it 'removes subjects' do
          expect(school_profile.reload.subjects).to be_empty
        end
      end

      context 'when school no longer has candidate requirements' do
        let :school_profile do
          FactoryBot.create :school_profile, :with_candidate_requirements_choice,
            :with_candidate_requirements_selection
        end

        let :candidate_requirements_choice do
          FactoryBot.build :candidate_requirements_choice,
            has_requirements: false
        end

        before do
          school_profile.update! \
            candidate_requirements_choice: candidate_requirements_choice
        end

        it 'removes subjects' do
          expect(school_profile.reload.candidate_requirements_selection).to \
            eq Schools::OnBoarding::CandidateRequirementsSelection.new
        end
      end

      context 'when school no longer supports access_needs' do
        let :school_profile do
          FactoryBot.create :school_profile,
            :with_access_needs_support,
            :with_access_needs_detail,
            :with_disability_confident,
            :with_access_needs_policy
        end

        let :no_access_needs_support do
          FactoryBot.build :access_needs_support, supports_access_needs: false
        end

        before do
          school_profile.update! access_needs_support: no_access_needs_support
        end

        it 'removes access_needs_detail' do
          expect(school_profile.access_needs_detail).to eq \
            Schools::OnBoarding::AccessNeedsDetail.new
        end

        it 'removes disability_confident' do
          expect(school_profile.disability_confident).to eq \
            Schools::OnBoarding::DisabilityConfident.new
        end

        it 'removes access_needs_policy' do
          expect(school_profile.access_needs_policy).to eq \
            Schools::OnBoarding::AccessNeedsPolicy.new
        end
      end
    end
  end

  context '#requires_subjects?' do
    let :school_profile do
      FactoryBot.create :school_profile
    end

    context 'when phases_list includes secondary' do
      before do
        school_profile.phases_list = \
          FactoryBot.build :phases_list, secondary: true, college: false
      end

      it 'returns true' do
        expect(school_profile.requires_subjects?).to be true
      end
    end

    context 'when phases_list includes college' do
      before do
        school_profile.phases_list = \
          FactoryBot.build :phases_list, secondary: false, college: true
      end

      it 'returns true' do
        expect(school_profile.requires_subjects?).to be true
      end
    end

    context "when phases_list doesn't include college or secondary" do
      it 'returns false' do
        expect(school_profile.requires_subjects?).to be false
      end
    end
  end
end
