class Cron::IdentifyClosedSchoolsJob < CronJob
  # Every Monday at 9am
  self.cron_expression = "0 9 * * 1"

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

    closed_schools.map(&method(:sentence)).join(" ")
  end

  def sentence(school)
    "#{school.name} is #{enabled_text(school)} (URN #{school.urn}#{replacement_urns_text(school)})."
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

  def reopened_urns
    @reopened_urns ||= reconciler.find_reopened_urns(closed_schools.pluck(:urn))
  end
end
