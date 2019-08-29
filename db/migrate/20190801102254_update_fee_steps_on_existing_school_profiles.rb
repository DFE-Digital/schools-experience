class UpdateFeeStepsOnExistingSchoolProfiles < ActiveRecord::Migration[5.2]
  class Schools::SchoolProfile < ApplicationRecord; end

  def change
    Schools::SchoolProfile.update_all \
      administration_fee_step_completed: true,
      dbs_fee_step_completed: true,
      other_fee_step_completed: true
  end
end
