class Cron::IdentifyClosedSchoolsJob < ApplicationJob
  SERVICE_INBOX = "school.experience@education.gov.uk".freeze
  EMPTY_TEXT = "There are no closed, on-boarded schools.".freeze

  def perform
    return unless Rails.env.production?

    NotifyEmail::ClosedOnboardedSchoolsSummary.new(
      to: SERVICE_INBOX,
      closed_onboarded_schools: closed_onboarded_schools,
    ).despatch_later!
  end

private

  def closed_onboarded_schools
    return EMPTY_TEXT if closed_schools.none?

    [
      titled_bullet_list("Schools that are disabled without replacements", schools_disabled_without_replacements),
      titled_bullet_list("Schools that are disabled with replacements", schools_disabled_with_replacements),
      titled_bullet_list("Schools that are enabled without replacements", schools_enabled_without_replacements),
      titled_bullet_list("Schools that are enabled with replacements", schools_enabled_with_replacements),
    ].compact.join.strip
  end

  def titled_bullet_list(title, schools)
    return unless schools.any?

    <<~MARKDOWN
      ## #{title}

      #{schools.map(&method(:sentence)).join}
    MARKDOWN
  end

  def sentence(school)
    "* #{school.name} (URN #{school.urn}#{replacement_urns_text(school)}).\n"
  end

  def enabled_text(school)
    school.enabled ? "enabled" : "disabled"
  end

  def replacement_urns_text(school)
    urns = reopened_urns[school.urn].to_sentence

    return if urns.blank?

    ", replacement URN(s) #{urns}"
  end

  def reconciler
    @reconciler ||= Bookings::Data::GiasReconciler.new
  end

  def closed_schools
    @closed_schools ||= reconciler.identify_onboarded_closed
  end

  def schools_disabled_without_replacements
    @schools_disabled_without_replacements ||=
      closed_schools.select { |school| school.disabled? && reopened_urns[school.urn].none? }
  end

  def schools_disabled_with_replacements
    @schools_disabled_with_replacements ||=
      closed_schools.select { |school| school.disabled? && reopened_urns[school.urn].any? }
  end

  def schools_enabled_without_replacements
    @schools_enabled_without_replacements ||=
      closed_schools.select { |school| school.enabled? && reopened_urns[school.urn].none? }
  end

  def schools_enabled_with_replacements
    @schools_enabled_with_replacements ||=
      closed_schools.select { |school| school.enabled? && reopened_urns[school.urn].any? }
  end

  def reopened_urns
    @reopened_urns ||= reconciler.find_reopened_urns(closed_schools.pluck(:urn))
  end
end
