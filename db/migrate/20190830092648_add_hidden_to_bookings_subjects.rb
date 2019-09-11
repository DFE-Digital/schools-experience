class AddHiddenToBookingsSubjects < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_subjects, :hidden, :boolean, default: false
    add_index :bookings_subjects, :hidden
  end
end
