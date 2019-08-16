require 'rails_helper'

describe Schools::OnBoarding::DbsRequirement, type: :model do
  let :too_long_text do
    51.times.map { 'word' }.join(' ')
  end

  context 'attributes' do
    it { is_expected.to respond_to :requires_check }
    it { is_expected.to respond_to :dbs_policy_details }
    it { is_expected.to respond_to :no_dbs_policy_details }
  end

  context 'before validation' do
    context 'when dbs_required' do
      before do
        subject.requires_check = true
        subject.no_dbs_policy_details = 'some details'
        subject.validate
      end

      it 'removes no dbs_policy_details' do
        expect(subject.no_dbs_policy_details).to be nil
      end
    end

    context 'when not dbs_required' do
      before do
        subject.requires_check = false
        subject.dbs_policy_details = 'some details'
        subject.validate
      end

      it 'removes dbs_policy_details' do
        expect(subject.dbs_policy_details).to be nil
      end
    end
  end

  context 'validations' do
    context 'when dbs_required' do
      before { subject.requires_check = true }

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

    context 'when not dbs_required' do
      before { subject.requires_check = false }

      it { is_expected.to validate_presence_of :no_dbs_policy_details }

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
