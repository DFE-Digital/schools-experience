module Schools
  module OnBoarding
    class AdminContactsController < OnBoardingsController
      def new
        @admin_contact = AdminContact.new
      end

      def create
        @admin_contact = AdminContact.new admin_contact_params

        if @admin_contact.valid?
          current_school_profile.update! admin_contact: @admin_contact
          continue(current_school_profile)
        else
          render :new
        end
      end

      def edit
        # NB: we must initialise new models when editing an existing one because
        # we are using the composed_of framework to build the components of
        # SchoolProfile. Otherwise, frozen variable errors will be triggered.
        @admin_contact = AdminContact.new(current_school_profile.admin_contact.attributes)
      end

      def update
        @admin_contact = AdminContact.new admin_contact_params

        if @admin_contact.valid?
          current_school_profile.update admin_contact: @admin_contact
          continue(current_school_profile)
        else
          render :edit
        end
      end

    private

      def admin_contact_params
        params.require(:schools_on_boarding_admin_contact).permit \
          :phone, :email, :email_secondary
      end
    end
  end
end
