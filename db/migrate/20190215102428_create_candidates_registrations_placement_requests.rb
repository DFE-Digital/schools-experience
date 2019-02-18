class CreateCandidatesRegistrationsPlacementRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :candidates_registrations_placement_requests do |t|
      t.date :date_start, null: false
      t.date :date_end, null: false
      t.text :objectives, null: false
      t.boolean :access_needs, null: false
      t.text :access_needs_details
      t.integer :urn, null: false
      t.string :degree_stage, null: false
      t.text :degree_stage_explaination
      t.string :degree_subject, null: false
      t.string :teaching_stage, null: false
      t.string :subject_first_choice, null: false
      t.string :subject_second_choice, null: false
      t.boolean :has_dbs_check, null: false

      t.timestamps
    end
  end
end
