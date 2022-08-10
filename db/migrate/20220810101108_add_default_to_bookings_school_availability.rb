class AddDefaultToBookingsSchoolAvailability < ActiveRecord::Migration[7.0]
  def up
    change_column_default :bookings_schools, :availability_info, default_availability_info
    change_column_default :bookings_schools, :experience_type, :inschool

    Bookings::School.where(availability_info: nil).update_all(availability_info: default_availability_info)
    Bookings::School.where(experience_type: nil).update_all(experience_type: :inschool)
  end

  def down
    change_column_default :bookings_schools, :availability_info, nil
    change_column_default :bookings_schools, :experience_type, nil

    Bookings::School.where(availability_info: default_availability_info).update_all(availability_info: nil)
  end

private

  def default_availability_info
    I18n.t("defaults.bookings_school.availability_info")
  end
end
