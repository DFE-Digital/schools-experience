class AddBookingsBookingAcceptanceFields < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_bookings, :placement_details, :text, null: true

    add_column :bookings_bookings, :contact_name, :string, null: true
    add_column :bookings_bookings, :contact_number, :string,  null: true
    add_column :bookings_bookings, :contact_email, :string, null: true
    add_column :bookings_bookings, :location, :text, null: true

    add_column :bookings_bookings, :candidate_instructions, :string, null: true
  end
end
