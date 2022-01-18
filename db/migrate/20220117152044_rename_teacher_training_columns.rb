class RenameTeacherTrainingColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :schools_school_profiles, :experience_outline_provides_teacher_training, :teacher_training_provides_teacher_training
    rename_column :schools_school_profiles, :experience_outline_teacher_training_details, :teacher_training_teacher_training_details
    rename_column :schools_school_profiles, :experience_outline_teacher_training_url, :teacher_training_teacher_training_url
  end
end
