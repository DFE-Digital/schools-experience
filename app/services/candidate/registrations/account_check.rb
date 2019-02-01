class Candidate::Registrations::AccountCheck
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :full_name
  attribute :email

  validates :full_name, presence: true
  validates :email, presence: true
end
