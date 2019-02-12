module Candidates
  module Registrations
    class AccountCheck < RegistrationStep
      attribute :full_name, :string
      attribute :email, :string

      validates :full_name, presence: true
      validates :email, presence: true
    end
  end
end
