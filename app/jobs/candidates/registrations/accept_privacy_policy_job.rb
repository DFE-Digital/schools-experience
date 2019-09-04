class Candidates::Registrations::AcceptPrivacyPolicyJob < GitisJob
  retry_on StandardError, wait: A_DECENT_AMOUNT_LONGER, attempts: 8

  def perform(contact_id, privacy_policy_id)
    contact = gitis.find(contact_id)

    gitis.write \
      Bookings::Gitis::CandidatePrivacyPolicy.build_for_contact \
        contact.id, privacy_policy_id
  end
end
