module Schools
  module PlacementDates
    class SubjectLimitForm
      include ActiveModel::Model

      COUNT_METHOD = %r(\Amax_bookings_count_for_subject_(\d+)\z).freeze
      COUNT_ASSIGNMENT = %r(\Amax_bookings_count_for_subject_(\d+)=\z).freeze

      attr_reader :subject_ids

      validate :validate_counts_for_subject_ids

      def self.new_from_date(placement_date)
        pairs = placement_date.subjects.pluck(:id, :name).to_h

        new(subject_ids: pairs.keys, subject_names: pairs).tap do |limits|
          placement_date.placement_date_subjects.each do |subj|
            limits.send \
              :"max_bookings_count_for_subject_#{subj.bookings_subject_id}=",
              subj.max_bookings_count
          end
        end
      end

      def initialize(subject_ids:, subject_names: nil)
        self.subject_ids = subject_ids
        @subject_names = subject_names
      end

      def save(placement_date)
        return false unless valid?

        Bookings::PlacementDate.transaction do
          assign_attributes_to_placement_date_subjects placement_date
          placement_date.published_at = DateTime.now
          placement_date.save!
        end
      end

      def method_missing(method_name, *args, &block)
        if (read_match = method_name.to_s.match(COUNT_METHOD))
          read_max_bookings_count_for_subject_id read_match[1].to_i
        elsif (write_match = method_name.to_s.match(COUNT_ASSIGNMENT))
          write_max_bookings_count_for_subject_id(write_match[1].to_i, args[0])
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name.to_s.match?(COUNT_METHOD) \
          || method_name.to_s.match?(COUNT_ASSIGNMENT) \
          || super
      end

      def subject_names
        @subject_names ||= retrieve_subject_names
      end

    private

      def field_name_for_subject_id(subject_id)
        "max_bookings_count_for_subject_#{subject_id}".to_sym
      end

      def subject_ids=(subj_ids)
        @subject_ids = Array.wrap(subj_ids).map(&:to_i)
      end

      def max_bookings_counts_for_subjects
        @max_bookings_counts_for_subjects ||= {}
      end

      def assign_attributes_to_placement_date_subjects(placement_date)
        placement_date.placement_date_subjects.each do |subject|
          subject.max_bookings_count =
            @max_bookings_counts_for_subjects[subject.bookings_subject_id]
        end
      end

      def read_max_bookings_count_for_subject_id(subject_id)
        if subject_ids.include? subject_id
          max_bookings_counts_for_subjects[subject_id]
        end
      end

      def write_max_bookings_count_for_subject_id(subject_id, count)
        if count.present? && subject_ids.include?(subject_id)
          max_bookings_counts_for_subjects[subject_id] = count.to_i
        end
      end

      def validate_counts_for_subject_ids
        subject_ids.each do |subject_id|
          if read_max_bookings_count_for_subject_id(subject_id).blank?
            add_error subject_id, :blank
          elsif read_max_bookings_count_for_subject_id(subject_id) < 1
            add_error subject_id, :greater_than, count: 0
          end
        end
      end

      def retrieve_subject_names
        Bookings::Subject.where(id: subject_ids).pluck(:id, :name).to_h
      end

      def add_error(subject_id, error, params = {})
        errors.add \
          field_name_for_subject_id(subject_id),
          error,
          params.merge(subject_name: subject_names[subject_id])
      end
    end
  end
end
