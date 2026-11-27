require 'rails_helper'

describe Candidates::Registrations::DbsRequirmentsChecker do
  let(:school) { instance_double(Bookings::School) }
  let(:profile) { instance_double(Bookings::Profile) }
  let(:bg_check) { instance_double(Candidates::Registrations::BackgroundCheck) }
  let(:current_registration) { instance_double(Candidates::Registrations::RegistrationSession) }
  let(:subject_and_date_information) { instance_double(Candidates::Registrations::SubjectAndDateInformation) }
  let(:placement_date) { instance_double(Bookings::PlacementDate) }
  let(:dbs_fees) { false }

  describe '#requirements_met?' do
    subject { described_class.new(school, bg_check, current_registration).requirements_met? }

    before do
      allow(profile).to receive_messages(dbs_policy_conditions: dbs_policy, dbs_fee_amount_pounds?: dbs_fees)
      allow(school).to receive_messages(profile: profile, availability_preference_fixed: fixed_dates)
      allow(bg_check).to receive(:has_dbs_check).and_return(has_dbs_check)
    end

    context 'with fixed placement dates' do
      let(:fixed_dates) { true }

      before do
        allow(current_registration).to receive(:subject_and_date_information)
          .and_return(subject_and_date_information)
        allow(subject_and_date_information).to receive(:placement_date).and_return(placement_date)
        allow(placement_date).to receive(:virtual).and_return(virtual_date)
      end

      context 'when school always requires dbs' do
        let(:dbs_policy) { "required" }

        context 'when candidate wants a virtual experience' do
          let(:virtual_date) { true }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be false }
          end
        end

        context 'when candidate wants an in-school experience' do
          let(:virtual_date) { false }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be false }
          end
        end
      end

      context 'when school does not requires dbs' do
        let(:dbs_policy) { "notrequired" }

        context 'when candidate wants a virtual experience' do
          let(:virtual_date) { true }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be true }
          end
        end

        context 'when candidate wants an in-school experience' do
          let(:virtual_date) { false }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be true }
          end
        end
      end

      context 'when school requires dbs and also does the dbs check for the candidates' do
        let(:dbs_policy) { "inschool" }
        let(:dbs_fees) { true }

        context 'when candidate wants an in-school experience' do
          let(:virtual_date) { false }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be true }
          end
        end
      end

      context 'when school requires dbs only for in-school experiences' do
        let(:dbs_policy) { "inschool" }

        context 'when candidate wants a virtual experience' do
          let(:virtual_date) { true }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be true }
          end
        end

        context 'when candidate wants an in-school experience' do
          let(:virtual_date) { false }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be false }
          end
        end
      end
    end

    context 'with flexible placement dates' do
      let(:fixed_dates) { false }

      before do
        allow(school).to receive(:experience_type).and_return(experience_type)
      end

      context 'when school always requires dbs' do
        let(:dbs_policy) { "required" }

        context 'when school offers only virtual experiences' do
          let(:experience_type) { 'virtual' }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be false }
          end
        end

        context 'when school offers only in-school experiences' do
          let(:experience_type) { 'inschool' }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be false }
          end
        end

        context 'when school offers both experiences' do
          let(:experience_type) { 'both' }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be false }
          end
        end
      end

      context 'when school does not requires dbs' do
        let(:dbs_policy) { "notrequired" }

        context 'when school offers only virtual experiences' do
          let(:experience_type) { 'virtual' }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be true }
          end
        end

        context 'when offers only in-school experiences' do
          let(:experience_type) { 'inschool' }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be true }
          end
        end

        context 'when school offers both experiences' do
          let(:experience_type) { 'both' }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be true }
          end
        end
      end

      context 'when school requires dbs and also does the dbs check for the candidates' do
        let(:dbs_policy) { "required" }
        let(:dbs_fees) { true }

        context 'when school offers only in-school experiences' do
          let(:experience_type) { 'inschool' }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be true }
          end
        end
      end

      context 'when school requires dbs only for in-school experiences' do
        let(:dbs_policy) { "inschool" }

        shared_examples 'a school offering virtual experiences' do
          context 'when candidate has dbs' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs' do
            let(:has_dbs_check) { false }

            it { is_expected.to be true }
          end
        end

        context 'when school offers only virtual experiences' do
          let(:experience_type) { 'virtual' }

          it_behaves_like 'a school offering virtual experiences'
        end

        context 'when school offers both experiences' do
          let(:experience_type) { 'both' }

          it_behaves_like 'a school offering virtual experiences'
        end

        context 'when school offers only in-school experience' do
          let(:experience_type) { 'inschool' }

          context 'when candidate has dbs check' do
            let(:has_dbs_check) { true }

            it { is_expected.to be true }
          end

          context 'when candidate does not have dbs check' do
            let(:has_dbs_check) { false }

            it { is_expected.to be false }
          end
        end
      end
    end
  end
end
