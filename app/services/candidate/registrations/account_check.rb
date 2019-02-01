module Candidate
  module Registrations
    class AccountCheck
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :full_name
      attribute :email

      validates :full_name, presence: true
      validates :email, presence: true
    end
  end
end
