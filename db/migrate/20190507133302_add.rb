class Add < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :candidate_experience_detail_times_flexible_details, :text
  end
end
