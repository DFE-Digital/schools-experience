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
          redirect_to new_candidates_school_registrations_address_path(current_school)
        else
          render :new
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
