class AddDataToBookingsSchoolTypes < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        school_type = Bookings::SchoolType.find_by(name: "Academy secure 16 to 19")
        if school_type
          school_type.update(edubase_id: 57)
        else
          Bookings::SchoolType.create(name: "Academy secure 16 to 19", edubase_id: 57)
        end
      end

      dir.down do
        Bookings::SchoolType.find_by(edubase_id: 57)&.destroy
      end
    end
  end
end
