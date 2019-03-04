module Candidates::SchoolHelper
  def format_school_address(school, separator = ", ")
    safe_join([
      school.address_1.presence,
      school.address_2.presence,
      school.address_3.presence,
      school.town.presence,
      school.county.presence,
      school.postcode.presence,
    ].compact, separator)
  end

  def format_school_subjects(school)
    safe_subjects = school.subjects.map(&:name).map do |subj|
      ERB::Util.h(subj)
    end

    safe_subjects.to_sentence.html_safe
  end

  def format_school_phases(school)
    safe_join school.phases.map(&:name), ', '
  end

  def describe_current_search(search)
    if search.latitude.present? && search.longitude.present?
      "near me"
    elsif search.location.to_s.present?
      "near #{search.location.to_s.humanize}"
    else
      "matching #{search.query.to_s.humanize}"
    end
  end

  def show_lower_navigation?(count)
    count >= 10
  end

  def school_location_map(school, zoom: 10)
    ajax_map(
      school.coordinates.latitude,
      school.coordinates.longitude,
      zoom: zoom,
      mapsize: "628,420",
      title: school.name,
      description: format_school_address(school, tag(:br))
    )
  end
end
