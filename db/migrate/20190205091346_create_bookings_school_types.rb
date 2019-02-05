class CreateBookingsSchoolTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_school_types do |t|
      t.string :name, limit: 64, null: false
      t.integer :edubase_id
      t.timestamps
    end

    add_index :bookings_school_types, :name, unique: true
  end
end
