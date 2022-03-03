class SetCandidateDressCodeCompletedForOnboardedSchools < ActiveRecord::Migration[6.1]
  def up
    Schools::SchoolProfile.find_each(batch_size: 100) do |profile|
      # A new column of candidate_dress_code_step_completed has been added with a default value of false.
      # This means that existing completed school profiles will be redirected to the candidate dress code step,
      # even though they have already completed it.
      #
      # The current_step of these profiles will be :candidate_dress_code. So, update their completed attributes to true.
      if profile.current_step == :candidate_dress_code
        # rubocop:disable Rails/SkipsModelValidations
        profile.update_attribute("candidate_dress_code_step_completed", true)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
