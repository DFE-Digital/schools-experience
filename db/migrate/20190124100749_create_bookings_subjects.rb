class CreateBookingsSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_subjects do |t|
      t.string :name, limit: 64
      t.timestamps
    end

    add_index :bookings_subjects, :name
  end
end
