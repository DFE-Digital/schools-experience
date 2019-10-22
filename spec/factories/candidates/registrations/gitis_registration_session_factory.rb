FactoryBot.define do
  factory :gitis_registration_session, parent: :flattened_registration_session,
    class: Candidates::Registrations::GitisRegistrationSession do

    gitis_contact { build(:gitis_contact, :persisted) }

    initialize_with do
      new \
        with
          .reduce("uuid" => uuid, "urn" => urn) { |options, step| options.merge(send(step)) },
        gitis_contact
    end
  end
end
