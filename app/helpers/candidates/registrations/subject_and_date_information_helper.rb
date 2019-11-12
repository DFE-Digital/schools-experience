module Candidates::Registrations::SubjectAndDateInformationHelper
  def subject_and_date_section_classes(subject_and_date_information)
    %w(subject-and-date-selection).tap { |classes|
      classes << 'subject-and-date-selection--error' if subject_and_date_information.errors.any?
    }.join(" ")
  end
end
