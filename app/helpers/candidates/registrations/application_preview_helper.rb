module Candidates::Registrations::ApplicationPreviewHelper
  def subject_and_date_description(placement_date, placement_date_subject)
    content_tag('ul', class: 'govuk-list') do
      safe_join(
        [
          tag.li(placement_date),
          (tag.li(placement_date_subject.bookings_subject.name) if placement_date_subject.present?)
        ]
      )
    end
  end
end
