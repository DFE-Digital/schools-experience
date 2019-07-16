class RenameSchoolsEmail2ToEmailSecondary < ActiveRecord::Migration[5.2]
  def change
    rename_column :bookings_profiles, :admin_contact_email2, :admin_contact_email_secondary
    rename_column :schools_school_profiles, :admin_contact_email2, :admin_contact_email_secondary
  end
end
