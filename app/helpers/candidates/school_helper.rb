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
    filtered_subject_ids = filtered_subject_ids(params[:subjects])

    subjects = school.subjects.ordered_by_name.map do |subject|
      if subject.id.in? filtered_subject_ids
        tag.strong(subject.name)
      else
        subject.name
      end
    end

    if subjects.empty?
      'Not specified'
    else
      to_sentence subjects
    end
  end

  def format_school_phases(school)
    content_tag(:ul, class: 'govuk-list') do
      safe_join(school.phases.map { |p| tag.li(p.name) })
    end
  end

  def format_school_availability(availability_info)
    availability_info.present? ? safe_format(availability_info) : 'No information supplied'
  end

  def format_phases(school)
    school.phases.map(&:name).to_sentence
  end

  def describe_current_search(search)
    if search.location_name.present?
      "near #{search.location_name}"
    elsif search.location.present?
      "near #{search.location}"
    else
      "matching #{search.query}"
    end
  end

  def show_lower_navigation?(count)
    count >= 10
  end

  def school_location_map(school, zoom: 10, described_by: nil)
    ajax_map(
      school.coordinates.latitude,
      school.coordinates.longitude,
      zoom: zoom,
      mapsize: "628,420",
      title: school.name,
      description: format_school_address(school, tag(:br)),
      described_by: described_by
    )
  end

  def gias_school_url(urn)
    "https://get-information-schools.service.gov.uk/Establishments/Establishment/Details/#{urn}"
  end

  def ofsted_report_url(urn)
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

  def cleanup_school_url(url)
    if url.blank?
      '#'
    elsif url.match? %{:}
      url
    elsif url.match? %r{.*@.*}
      "mailto:#{url}"
    else
      "http://#{url}"
    end
  end

  def school_new_search_params
    params.permit(:location, :latitude, :longitude).reject { |_, v| v.blank? }
  end

  def dlist_item(key, attrs = {}, &block)
    classes = ['govuk-summary-list__row', attrs[:class]].flatten.compact.join(' ')

    content_tag :div, attrs.merge(class: classes) do
      content_tag(:dt, key, class: 'govuk-summary-list__key') +
        content_tag(:dd, class: 'govuk-summary-list__value', &block)
    end
  end

  def content_or_msg(content, msg = nil)
    if block_given?
      msg = yield
    elsif msg
      msg = content_tag(:em, msg)
    end

    content.presence || msg
  end

  def start_request_link(school)
    if school.availability_preference_fixed?
      new_candidates_school_registrations_subject_and_date_information_path(school)
    else
      new_candidates_school_registrations_personal_information_path(school)
    end
  end

  def split_to_list(content)
    return nil if content.nil?

    items = content.split("\n").reject(&:blank?)

    return nil if items.blank?

    content_tag('ul', class: 'govuk-list govuk-list--bullet') do
      safe_join(items.map { |req| tag.li(req) })
    end
  end

private

  def filtered_subject_ids(subject_ids)
    return [] unless subject_ids&.any?

    subject_ids.reject(&:blank?).map(&:to_i)
  end
end
