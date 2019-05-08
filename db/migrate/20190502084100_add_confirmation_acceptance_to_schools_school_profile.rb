class AddConfirmationAcceptanceToSchoolsSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :confirmation_acceptance, :boolean, default: false
  end
end
