class MakeSubjectAndPhaseNamesNotNullable < ActiveRecord::Migration[5.2]
  def change
    change_column :bookings_phases, :name, :string, limit: 32, null: false
    change_column :bookings_subjects, :name, :string, limit: 64, null: false
  end
end
