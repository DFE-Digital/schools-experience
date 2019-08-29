class CreateBookingsPlacementDateSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_placement_date_subjects do |t|
      t.belongs_to :bookings_placement_date, foreign_key: true, index: {
        name: :index_placement_date_subject_on_date_id
      }
      t.belongs_to :bookings_subject, foreign_key: true, index: {
        name: :index_placement_date_subject_on_subject_id
      }

      t.timestamps
    end
  end
end
