class AddDfeSigninOrganisationUuidToBookingsSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_schools, :dfe_signin_organisation_uuid, :uuid, null: true
  end
end
