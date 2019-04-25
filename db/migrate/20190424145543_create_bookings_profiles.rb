class CreateBookingsProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_profiles do |t|
      t.references  :school, index: true
      t.string      :dbs_required, null: false
      t.text        :dbs_policy
      t.text        :individual_requirements
      t.boolean     :primary_phase, null: false
      t.boolean     :secondary_phase, null: false
      t.boolean     :college_phase, null: false
      t.boolean     :key_stage_early_years, null: false
      t.boolean     :key_stage_1, null: false
      t.boolean     :key_stage_2, null: false
      t.text        :specialism_details
      t.boolean     :dress_code_business, null: false
      t.boolean     :dress_code_cover_tattoos, null: false
      t.boolean     :dress_code_remove_piercings, null: false
      t.boolean     :dress_code_smart_casual, null: false
      t.text        :dress_code_other_details
      t.boolean     :parking_provided, null: false
      t.text        :parking_details, null: false
      t.text        :disabled_facilities
      t.string      :start_time, null: false
      t.string      :end_time, null: false
      t.boolean     :flexible_on_times, null: false
      t.text        :placement_info, null: false
      t.text        :teacher_training_info
      t.string      :teacher_training_website
      t.string      :admin_contact_full_name, null: false
      t.string      :admin_contact_email, null: false
      t.string      :admin_contact_phone, null: false
      t.boolean     :fixed_availability, null: false
      t.text        :availability_info
      t.decimal     :administration_fee_amount_pounds, precision: 6, scale: 2
      t.text        :administration_fee_description
      t.string      :administration_fee_interval
      t.text        :administration_fee_payment_method
      t.decimal     :dbs_fee_amount_pounds, precision: 6, scale: 2
      t.text        :dbs_fee_description
      t.string      :dbs_fee_interval
      t.text        :dbs_fee_payment_method
      t.decimal     :other_fee_amount_pounds, precision: 6, scale: 2
      t.text        :other_fee_description
      t.string      :other_fee_interval
      t.text        :other_fee_payment_method

      t.timestamps
    end

    add_foreign_key :bookings_profiles, :bookings_schools, column: :school_id
  end
end
