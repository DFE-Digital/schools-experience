class RenameBookingsSchoolAttributes < ActiveRecord::Migration[5.2]
  def change
    rename_column :bookings_schools, :school_experience_description, :placement_info
    rename_column :bookings_schools, :school_experience_availability_details, :availability_info
    rename_column :bookings_schools, :primary_key_stage_details, :primary_key_stage_info
    rename_column :bookings_schools, :teacher_training_details, :teacher_training_info
    rename_column :bookings_schools, :itt_website, :teacher_training_website
  end
end
