require 'rails_helper'

describe Schools::SchoolProfile, type: :model do
  context 'candidate_requirement' do
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
    end

    context 'validations' do
      it do
        is_expected.to validate_presence_of :urn
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
    end
  end
end
