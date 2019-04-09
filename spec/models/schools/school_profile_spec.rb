require 'rails_helper'

describe Schools::SchoolProfile, type: :model do
  context 'attributes' do
    it do
      is_expected.to have_db_column(:urn).of_type :integer
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
      is_expected.to have_db_column(:specialism_has_specialism).of_type :boolean
    end

    it do
      is_expected.to have_db_column(:specialism_details).of_type :text
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
      is_expected.to have_db_column(:admin_contact_email).of_type :string
    end
  end

  context 'validations' do
    it do
      is_expected.to validate_presence_of :urn
    end
  end

  context 'associations' do
    context 'subjects' do
      subject { described_class.create! urn: 1234567890 }

      let! :secondary_phase do
        FactoryBot.create :bookings_phase, :secondary
      end

      let! :college_phase do
        FactoryBot.create :bookings_phase, :college
      end

      let :secondary_subject do
        FactoryBot.create :bookings_subject
      end

      let :college_subject do
        FactoryBot.create :bookings_subject
      end

      before do
        subject.secondary_subjects << secondary_subject
        subject.college_subjects << college_subject
      end

      context '#secondary_subjects' do
        it 'only returns secondary subjects' do
          expect(subject.secondary_subjects.to_a).to eq [secondary_subject]
        end
      end

      context '#college_subjects' do
        it 'only returns college subjects' do
          expect(subject.college_subjects.to_a).to eq [college_subject]
        end
      end
    end
  end

  context 'values from form models' do
    let :model do
      described_class.new urn: 1234567890
    end

    context '#candidate_requirement' do
      let :form_model do
        FactoryBot.build :candidate_requirement
      end

      before do
        model.candidate_requirement = form_model
      end

      it 'sets candidate_requirement_dbs_requirement' do
        expect(model.candidate_requirement_dbs_requirement).to eq \
          form_model.dbs_requirement
      end

      it 'sets candidate_requirement_dbs_policy' do
        expect(model.candidate_requirement_dbs_policy).to eq \
          form_model.dbs_policy
      end

      it 'sets candidate_requirement_requirements' do
        expect(model.candidate_requirement_requirements).to eq \
          form_model.requirements
      end

      it 'sets candidate_requirement_requirements_details' do
        expect(model.candidate_requirement_requirements_details).to eq \
          form_model.requirements_details
      end

      it 'returns the form model' do
        expect(model.candidate_requirement).to eq form_model
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

    context '#specialism' do
      let :form_model do
        FactoryBot.build :specialism
      end

      before do
        model.specialism = form_model
      end

      it 'sets has_specialism' do
        expect(model.specialism_has_specialism).to eq form_model.has_specialism
      end

      it 'sets details' do
        expect(model.specialism_details).to eq form_model.details
      end

      it 'returns the form model' do
        expect(model.specialism).to eq form_model
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

      %i(full_name phone email).each do |attribute|
        it "sets #{attribute} correctly" do
          expect(model.send("admin_contact_#{attribute}")).to \
            eq form_model.send attribute
        end
      end

      it 'returns the form model' do
        expect(model.admin_contact).to eq form_model
      end
    end
  end
end
