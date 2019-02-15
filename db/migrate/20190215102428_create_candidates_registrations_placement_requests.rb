class CreateCandidatesRegistrationsPlacementRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :candidates_registrations_placement_requests do |t|
      t.date :date_start
      t.date :date_end
      t.text :objectives
      t.boolean :access_needs
      t.text :access_needs_details
      t.string :urn
      t.string :degree_stage
      t.text :degree_stage_explanination
      t.string :degree_subject
      t.string :teaching_stage
      t.string :subject_first_choice
      t.string :subject_second_choice
      t.boolean :has_dbs_check

      t.timestamps
    end
  end
end
