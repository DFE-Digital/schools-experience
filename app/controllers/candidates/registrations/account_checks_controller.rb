module Candidates
  module Registrations
    class AccountChecksController < RegistrationsController
      def new
        @account_check = AccountCheck.new
      end

      def create
        @account_check = AccountCheck.new account_check_params
        if @account_check.valid?
          persist @account_check
          redirect_to new_candidates_school_registrations_address_path
        else
          render :new
        end
      end

      def edit
        # TODO think about this
        # Not sure on this,
        # seems like one might expect
        # @account.update to work
        # maybe current_registration.fetch Klass is better?
        @account_check = current_registration.account_check
      end

      def update
        @account_check = current_registration.account_check
        @account_check.assign_attributes account_check_params

        if @account_check.valid?
          persist @account_check
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def account_check_params
        params.require(:candidates_registrations_account_check).permit \
          :full_name,
          :email
      end
    end
  end
end
