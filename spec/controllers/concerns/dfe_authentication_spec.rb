require 'rails_helper'

describe DFEAuthentication do
  # testing is much easier with an _actual_ controller, so
  # let's use Dashboards
  describe Schools::DashboardsController, type: :controller do
    it { expect(described_class.ancestors).to include(DFEAuthentication) }

    let(:teacher) { { name: "Seymour Skinner" } }
    context '#current_user' do
      context 'when the current_user is set' do
        before do
          subject.instance_variable_set(:@current_user, teacher)
        end

        specify 'should return the current user' do
          expect(subject.send(:current_user)).to eql(teacher)
        end
      end

      context 'when the current user is not set' do
        before { get :show }
        before { controller.session[:current_user] = teacher }

        specify 'should retrieve the current user from the session' do
          expect(subject.send(:current_user)).to eql(teacher)
        end
      end
    end

    context '#user_signed_in?' do
      context 'when a user is signed in' do
        before do
          subject.instance_variable_set(:@current_user, teacher)
        end

        it 'should be true' do
          expect(subject.send(:user_signed_in?)).to be(true)
        end
      end

      context 'when a user is not signed in' do
        it 'should be false' do
          expect(subject.send(:user_signed_in?)).to be(false)
        end
      end
    end

    describe '#school_urns' do
      before do
        allow(controller).to receive(:retrieve_school_uuids).and_return \
          SecureRandom.uuid => 4,
          SecureRandom.uuid => 5,
          SecureRandom.uuid => 6
      end

      context 'with nothing loaded' do
        it { expect(subject.send(:school_urns)).to eql [4, 5, 6] }
      end

      context 'with loaded' do
        before do
          controller.session[:uuid_map] = {
            SecureRandom.uuid => 1,
            SecureRandom.uuid => 2,
            SecureRandom.uuid => 3
          }
        end
        it { expect(subject.send(:school_urns)).to eql [1, 2, 3] }
      end

      context 'with forced reload' do
        before { controller.session[:urns] = [1, 2, 3] }
        it { expect(subject.send(:school_urns, true)).to eql [4, 5, 6] }
        it { expect(controller).not_to have_received(:retrieve_school_uuids) }
      end
    end

    describe '#other_school_urns' do
      before { allow(controller).to receive(:school_urns) { [1, 2, 3] } }
      before { allow(controller).to receive(:current_school) { build(:bookings_school, urn: 2) } }
      it { expect(subject.send(:other_school_urns)).to eql [1, 3] }
    end

    describe '#has_other_schools' do
      context 'when other schools' do
        before { allow(controller).to receive(:other_school_urns) { [1, 2] } }
        it { expect(subject.send(:has_other_schools?)).to be true }
      end

      context 'when only one school' do
        before { allow(Schools::DFESignInAPI::Client).to receive(:enabled?) { true } }
        before { allow(controller).to receive(:other_school_urns) { [] } }
        it { expect(subject.send(:has_other_schools?)).to be false }
      end
    end
  end
end
