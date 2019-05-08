module Schools
  module OnBoarding
    class ExperienceOutline < Step
      attribute :candidate_experience, :string
      attribute :provides_teacher_training, :boolean
      attribute :teacher_training_details, :string
      attribute :teacher_training_url, :string

      validates :provides_teacher_training, inclusion: [true, false]
      validates :teacher_training_details, presence: true, if: :provides_teacher_training
      validates :teacher_training_url, format: URI::regexp(%w(http https)), if: -> { teacher_training_url.present? }

      def self.compose(
        candidate_experience,
        provides_teacher_training,
        teacher_training_details,
        teacher_training_url
      )
        new \
          candidate_experience: candidate_experience,
          provides_teacher_training: provides_teacher_training,
          teacher_training_details: teacher_training_details,
          teacher_training_url: teacher_training_url
      end
    end
  end
end
