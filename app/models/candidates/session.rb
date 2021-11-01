class Candidates::Session
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_reader :contact, :candidate, :token

  attribute :email, :string
  attribute :firstname, :string
  attribute :lastname, :string

  validates :email, presence: true
  validates :email, format: /\A[^@]+@[^@]+\.[^@]+\z/, allow_blank: true
  validates :firstname, presence: true
  validates :lastname, presence: true

  def self.signin!(token_string)
    token = Candidates::SessionToken.valid.find_by(token: token_string)
    return unless token

    token.confirm!.candidate
  end
end
