module Schools
  module OnBoarding
    class SubjectList
      include ActiveModel::Model

      attr_reader :subject_ids

      def subject_ids=(array)
        @subject_ids = array.reject(&:blank?).map(&:to_i)
      end

      validate :at_least_one_subject_selected
      validate :all_subjects_are_available, if: -> { at_least_one_subject_selected? }

      def ==(other)
        return false unless other.respond_to? :subject_ids

        Array(other.subject_ids).all? do |subject_id|
          Array(self.subject_ids).include? subject_id
        end
      end

      def available_subjects
        Bookings::Subject.all
      end

    private

      def at_least_one_subject_selected
        unless at_least_one_subject_selected?
          errors.add :base, :no_subject_selected
        end
      end

      def at_least_one_subject_selected?
        !subject_ids.empty?
      end

      def all_subjects_are_available
        unless all_subjects_are_available?
          errors.add :base, :invalid_subject_selected
        end
      end

      def all_subjects_are_available?
        available_subjects_ids = available_subjects.pluck :id

        subject_ids.all? do |subject_id|
          available_subjects_ids.include? subject_id
        end
      end
    end
  end
end
