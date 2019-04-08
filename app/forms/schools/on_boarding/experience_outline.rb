module Schools
  module OnBoarding
    class ExperienceOutline
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :candidate_experience, :string
      attribute :provides_teacher_training, :boolean
      attribute :teacher_training_details, :string
      attribute :teacher_training_url, :string

      validates :candidate_experience, presence: true
      validates :provides_teacher_training, inclusion: [true, false]
      validates :teacher_training_details, presence: true, if: :provides_teacher_training
      # TODO validate url format
      validates :teacher_training_url, presence: true, if: :provides_teacher_training
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

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end
    end
  end
end
