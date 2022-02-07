class CreateCandidatesBookingFeedbacks < ActiveRecord::Migration[6.1]
  def change
    create_table :candidates_booking_feedbacks do |t|
      t.belongs_to :bookings_booking, foreign_key: true, index: { unique: true }

      t.boolean :gave_realistic_impression
      t.boolean :covered_subject_of_interest
      t.boolean :influenced_decision
      t.boolean :intends_to_apply
      t.integer :effect_on_decision

      t.timestamps
    end
  end
end
