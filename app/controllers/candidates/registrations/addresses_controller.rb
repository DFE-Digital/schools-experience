module Candidates
  module Registrations
    class AddressesController < RegistrationsController
      def new
        @address = Address.new
      end

      def create
        @address = Address.new address_params
        if @address.valid?
          current_registration[:address] = @address.attributes
          redirect_to new_candidates_registrations_subject_preference_path
        else
          render :new
        end
      end

    private

      def address_params
        params.require(:candidates_registrations_address).permit \
          :building,
          :street,
          :town_or_city,
          :county,
          :postcode,
          :phone
      end
    end
  end
end
