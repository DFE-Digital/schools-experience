require 'rails_helper'

describe Candidates::Registrations::DbsRequirmentsChecker do
  let(:school) { double(:school) }
  let(:bg_check) { double(:bg_check) }
  let(:current_registration) { double(:current_registration) }

  describe '#rejected?' do
    subject { described_class.new(school, bg_check, current_registration).requirements_met? }

    before do
      allow(school).to receive_message_chain('profile.dbs_policy_conditions').and_return(dbs_policy)
      allow(bg_check).to receive(:has_dbs_check).and_return(dbs_check)
      allow(current_registration).to \
        receive_message_chain('subject_and_date_information.placement_date.virtual?')
        .and_return(virtual_date)
    end

    context 'when school does not requires dbs check' do
      let(:dbs_policy) { "notrequired" }

      context 'when candidate wants a virtual experience' do
        let(:virtual_date) { true }

        context 'when candidate has dbs check' do
          let(:dbs_check) { true }

          it { is_expected.to be true }
        end

        context 'when candidate does not have dbs check' do
          let(:dbs_check) { false }

          it { is_expected.to be true }
        end
      end

      context 'when candidate wants an in-school experience' do
        let(:virtual_date) { false }

        context 'when candidate has dbs check' do
          let(:dbs_check) { true }

          it { is_expected.to be true }
        end

        context 'when candidate does not have dbs check' do
          let(:dbs_check) { false }

          it { is_expected.to be true }
        end
      end
    end

    context 'when school always requires dbs check' do
      let(:dbs_policy) { "required" }

      context 'when candidate wants a virtual experience' do
        let(:virtual_date) { true }

        context 'when candidate has dbs check' do
          let(:dbs_check) { true }

          it { is_expected.to be true }
        end

        context 'when candidate does not have dbs check' do
          let(:dbs_check) { false }

          it { is_expected.to be false }
        end
      end

      context 'when candidate wants an in-school experience' do
        let(:virtual_date) { false }

        context 'when candidate has dbs check' do
          let(:dbs_check) { true }

          it { is_expected.to be true }
        end

        context 'when candidate does not have dbs check' do
          let(:dbs_check) { false }

          it { is_expected.to be false }
        end
      end
    end

    context 'when school requires dbs check only for in-school experiences' do
      let(:dbs_policy) { "inschool" }

      context 'when candidate wants a virtual experience' do
        let(:virtual_date) { true }

        context 'when candidate has dbs check' do
          let(:dbs_check) { true }

          it { is_expected.to be true }
        end

        context 'when candidate does not have dbs check' do
          let(:dbs_check) { false }

          it { is_expected.to be true }
        end
      end

      context 'when candidate wants an in-school experience' do
        let(:virtual_date) { false }

        context 'when candidate has dbs check' do
          let(:dbs_check) { true }

          it { is_expected.to be true }
        end

        context 'when candidate does not have dbs check' do
          let(:dbs_check) { false }

          it { is_expected.to be false }
        end
      end
    end
  end
end
