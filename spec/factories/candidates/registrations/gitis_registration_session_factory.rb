FactoryBot.define do
  factory :gitis_registration_session, parent: :registration_session,
    class: Candidates::Registrations::GitisRegistrationSession do

    gitis_contact { build(:gitis_contact, :persisted) }

    initialize_with do
      new \
        with
          .map { |step| "candidates_registrations_#{step}" }
          .reduce("uuid" => uuid, "urn" => urn) { |options, step| options.merge step => send(step) },
        gitis_contact
    end
  end
end
