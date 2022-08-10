class MakeAvailabilityInfoAndExperienceTypeNotNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :bookings_schools, :availability_info, false
    change_column_null :bookings_schools, :experience_type, false
  end
end
