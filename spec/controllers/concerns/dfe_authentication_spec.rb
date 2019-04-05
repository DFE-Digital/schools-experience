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
          expect(subject.current_user).to eql(teacher)
        end
      end

      context 'when the current user is not set' do
        before { get :show }
        before { controller.session[:current_user] = teacher }

        specify 'should retrieve the current user from the session' do
          expect(subject.current_user).to eql(teacher)
        end
      end
    end

    context '#user_signed_in?' do
      context 'when a user is signed in' do
        before do
          subject.instance_variable_set(:@current_user, teacher)
        end

        it 'should be true' do
          expect(subject.user_signed_in?).to be(true)
        end
      end

      context 'when a user is not signed in' do
        it 'should be false' do
          expect(subject.user_signed_in?).to be(false)
        end
      end
    end
  end
end
