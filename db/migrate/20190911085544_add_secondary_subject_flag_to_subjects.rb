class AddSecondarySubjectFlagToSubjects < ActiveRecord::Migration[5.2]
  def up
    add_column :bookings_subjects, :secondary_subject, :boolean, null: false, default: true

    Bookings::Subject.reset_column_information

    Bookings::Subject.find_by(name: 'Primary').update(secondary_subject: false)
  end

  def down
    remove_column :bookings_subjects, :secondary_subject, :boolean
  end
end
