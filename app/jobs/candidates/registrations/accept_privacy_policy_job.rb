class Candidates::Registrations::AcceptPrivacyPolicyJob < GitisJob
  retry_on StandardError, wait: A_DECENT_AMOUNT_LONGER, attempts: 8

  def perform(contact_id, policy_id)
    Bookings::Gitis::AcceptPrivacyPolicy
      .new(gitis, contact_id, policy_id)
      .accept!
  end
end
