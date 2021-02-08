module Candidates::Registrations::SubjectAndDateInformationHelper
  def subject_and_date_section_classes(subject_and_date_information)
    %w[subject-and-date-selection].tap { |classes|
      classes << 'subject-and-date-selection--error' if subject_and_date_information.errors.any?
    }.join(" ")
  end

  def format_primary_date_options(options)
    options.map do |option|
      [
        option.id,
        tag.span(option.name_with_duration) +
          placement_date_experience_type_tag(option.virtual)
      ]
    end
  end
end
