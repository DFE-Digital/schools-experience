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

  def format_school_availability(school)
    simple_format school.try(:availability_info) || 'Not specified'
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

  def gias_school_url(urn)
    "https://get-information-schools.service.gov.uk/Establishments/Establishment/Details/#{urn}"
  end

  def offsted_report_url(urn)
    "http://www.ofsted.gov.uk/oxedu_providers/full/(urn)/#{urn}"
  end

  def performance_report_url(urn)
    "https://www.compare-school-performance.service.gov.uk/school/#{urn}"
  end

  def school_search_phase_filter_description(search)
    return if search.phases.empty?

    t(
      'helpers.candidates.school_search.phases_filter_html',
      phase_names: to_sentence(search.phase_names.map { |name| content_tag(:strong, name) })
    )
  end

  def school_search_subject_filter_description(search)
    return if search.subjects.empty?

    t(
      'helpers.candidates.school_search.subjects_filter_html',
      subject_names: to_sentence(search.subject_names.map { |name| content_tag(:strong, name) })
    )
  end
end
