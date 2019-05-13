class CreateSchoolsOnBoardingPhaseSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :schools_on_boarding_phase_subjects do |t|
      t.belongs_to :schools_school_profile, foreign_key: true, index: {
        name: :index_phase_subjects_on_school_profile_id
      }
      t.belongs_to :bookings_phase, foreign_key: true
      t.belongs_to :bookings_subject, foreign_key: true

      t.timestamps
    end
  end
end
