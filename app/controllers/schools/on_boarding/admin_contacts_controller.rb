module Schools
  module OnBoarding
    class AdminContactsController < OnBoardingsController
      def new
        @admin_contact = AdminContact.new
      end

      def create
        @admin_contact = AdminContact.new admin_contact_params

        if @admin_contact.valid?
          current_school_profile.update admin_contact: @admin_contact
          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

    private

      def admin_contact_params
        params.require(:schools_on_boarding_admin_contact).permit \
          :full_name, :phone, :email
      end
    end
  end
end
