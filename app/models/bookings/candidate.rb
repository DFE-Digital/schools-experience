class Bookings::Candidate < ApplicationRecord
  UUID_V4_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/.freeze
  attr_accessor :gitis_contact
  alias_method :contact, :gitis_contact

  # delete_all used since there may be a lot of tokens
  # and the tokens don't have any real logic
  has_many :session_tokens,
              class_name: 'Candidates::SessionToken',
              dependent: :delete_all

  has_many :placement_requests,
              class_name: 'Bookings::PlacementRequest',
              inverse_of: :candidate,
              dependent: :destroy

  has_many :bookings, through: :placement_requests

  validates :gitis_uuid, presence: true, format: { with: Bookings::Gitis::Entity::ID_FORMAT }
  validates :gitis_uuid, uniqueness: { case_sensitive: false }

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  delegate :full_name, :email, to: :gitis_contact

  class << self
    def find_or_create_from_gitis_contact!(contact)
      find_or_create_by!(gitis_uuid: contact.id).tap do |c|
        c.gitis_contact = contact
      end
    end

    def find_by_gitis_contact(contact)
      candidate = find_by(gitis_uuid: contact.id)
      return nil unless candidate

      candidate.tap do |c|
        c.gitis_contact = contact
      end
    end

    def find_by_gitis_contact!(contact)
      find_by!(gitis_uuid: contact.id).tap do |c|
        c.gitis_contact = contact
      end
    end

    def create_or_update_from_registration_session!(crm, registration, contact)
      if contact
        find_or_create_from_gitis_contact!(contact) \
          .update_from_registration_session!(crm, registration)
      else
        create_from_registration_session!(crm, registration)
      end
    end

    def create_from_registration_session!(crm, registration)
      mapper = Bookings::RegistrationContactMapper.new \
        registration, Bookings::Gitis::Contact.new

      contact = mapper.registration_to_contact
      crm.write contact

      create!(gitis_uuid: contact.id, confirmed_at: Time.zone.now, created_in_gitis: true).tap do |candidate|
        candidate.gitis_contact = contact
      end
    end
  end

  def generate_session_token!
    session_tokens.create!
  end

  def expire_session_tokens!
    session_tokens.expire_all!
  end

  def confirmed?
    confirmed_at?
  end

  def last_signed_in_at
    confirmed_at || session_tokens.confirmed.maximum(:confirmed_at)
  end

  def update_from_registration_session!(crm, registration)
    mapper = Bookings::RegistrationContactMapper.new \
      registration, gitis_contact

    mapper.registration_to_contact
    crm.write gitis_contact

    self
  end

  def fetch_gitis_contact(crm)
    raise NoGitisUuid unless gitis_uuid?

    self.gitis_contact = crm.find(gitis_uuid)
  end

  class NoGitisUuid < RuntimeError; end
end
