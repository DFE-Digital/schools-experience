require 'rails_helper'

describe Schools::OnBoarding::DbsRequirement, type: :model do
  let :too_long_text do
    51.times.map { 'word' }.join(' ')
  end

  context 'attributes' do
    it { is_expected.to respond_to :dbs_policy_conditions }
    it { is_expected.to respond_to :dbs_policy_details }
    it { is_expected.to respond_to :no_dbs_policy_details }
  end

  context 'before validation' do
    context 'when dbs_policy_conditions is required' do
      before do
        subject.dbs_policy_conditions = 'required'
        subject.no_dbs_policy_details = 'some details'
        subject.validate
      end

      it 'removes no dbs_policy_details' do
        expect(subject.no_dbs_policy_details).to be nil
      end
    end

    context 'when dbs_policy_conditions is inschool' do
      before do
        subject.dbs_policy_conditions = 'inschool'
        subject.no_dbs_policy_details = 'some details'
        subject.validate
      end

      it 'removes no dbs_policy_details' do
        expect(subject.no_dbs_policy_details).to be nil
      end
    end

    context 'when dbs_policy_conditions is notrequired' do
      before do
        subject.dbs_policy_conditions = 'notrequired'
        subject.dbs_policy_details = 'some details'
        subject.validate
      end

      it 'removes dbs_policy_details' do
        expect(subject.dbs_policy_details).to be nil
      end
    end
  end

  context 'validations' do
    context 'when dbs_policy_conditions is required' do
      before { subject.dbs_policy_conditions = 'required' }

      it { is_expected.to validate_presence_of :dbs_policy_details }

      context 'word counts' do
        before { subject.dbs_policy_details = too_long_text }
        before { subject.validate }

        it "valdiates word count is no more than 50 words" do
          expect(subject.errors[:dbs_policy_details]).to \
            eq ['Use 50 words or fewer']
        end
      end
    end

    context 'when dbs_policy_conditions is inschool' do
      before { subject.dbs_policy_conditions = 'inschool' }

      it { is_expected.to validate_presence_of :dbs_policy_details_inschool }

      context 'word counts' do
        before { subject.dbs_policy_details_inschool = too_long_text }
        before { subject.validate }

        it "valdiates word count is no more than 50 words" do
          expect(subject.errors[:dbs_policy_details_inschool]).to \
            eq ['Use 50 words or fewer']
        end
      end
    end

    context 'when dbs_policy_conditions is notrequired' do
      before { subject.dbs_policy_conditions = 'notrequired' }

      context 'word counts' do
        before { subject.no_dbs_policy_details = too_long_text }
        before { subject.validate }

        it "valdiates word count is no more than 50 words" do
          expect(subject.errors[:no_dbs_policy_details]).to \
            eq ['Use 50 words or fewer']
        end
      end
    end
  end
end
