class AddQuestionnaireFieldsToBookingsSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_schools, :school_experience_description, :text
    add_column :bookings_schools, :teacher_training_provider, :boolean, default: false, null: false
    add_column :bookings_schools, :teacher_training_details, :text
    add_column :bookings_schools, :primary_key_stage_details, :text
    add_column :bookings_schools, :school_experience_availability_details, :text
  end
end
