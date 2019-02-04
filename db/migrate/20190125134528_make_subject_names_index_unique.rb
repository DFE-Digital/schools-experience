class MakeSubjectNamesIndexUnique < ActiveRecord::Migration[5.2]
  def change
    remove_index :bookings_subjects, :name
    add_index :bookings_subjects, :name, unique: true
  end
end
