class Bookings::Candidate < ApplicationRecord
  attr_accessor :gitis_contact
  alias_method :contact, :gitis_contact

  GITIS_ID_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/

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
  has_many :events,
    inverse_of: :bookings_candidate,
    foreign_key: :bookings_candidate_id,
    dependent: :destroy

  validates :gitis_uuid, presence: true, format: { with: GITIS_ID_FORMAT }
  validates :gitis_uuid, uniqueness: { case_sensitive: false }

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  alias_attribute :contact_uuid, :gitis_uuid

  delegate :email, to: :gitis_contact

  class << self
    def find_or_create_from_gitis_contact!(contact)
      find_or_create_by!(gitis_uuid: contact.candidate_id).tap do |c|
        c.gitis_contact = contact
      end
    end

    def find_by_gitis_contact(contact)
      candidate = find_by(gitis_uuid: contact.candidate_id)
      return nil unless candidate

      candidate.tap do |c|
        c.gitis_contact = contact
      end
    end

    def find_by_gitis_contact!(contact)
      find_by!(gitis_uuid: contact.candidate_id).tap do |c|
        c.gitis_contact = contact
      end
    end

    def create_or_update_from_registration_session!(registration, contact)
      if contact
        find_or_create_from_gitis_contact!(contact) \
          .update_from_registration_session!(registration)
      else
        create_from_registration_session!(registration)
      end
    end

    def create_from_registration_session!(registration)
      gitis_contact = GetIntoTeachingApiClient::SchoolsExperienceSignUp.new

      mapper = Bookings::RegistrationContactMapper.new \
        registration, gitis_contact

      mapped_contact = mapper.registration_to_contact
      contact = api_write_contact(mapped_contact)

      create!(gitis_uuid: contact.candidate_id, confirmed_at: Time.zone.now, created_in_gitis: true).tap do |candidate|
        candidate.gitis_contact = contact
      end
    end

    def api_write_contact(contact)
      api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
      api.sign_up_schools_experience_candidate(contact)
    end
  end

  def generate_session_token!
    session_tokens.create!
  end

  def expire_session_tokens!
    session_tokens.expire_all!
  end

  def full_name
    "#{gitis_contact.first_name} #{gitis_contact.last_name}"
  end

  def confirmed?
    confirmed_at?
  end

  def last_signed_in_at
    confirmed_at || session_tokens.confirmed.maximum(:confirmed_at)
  end

  def update_from_registration_session!(registration)
    mapper = Bookings::RegistrationContactMapper.new \
      registration, gitis_contact

    mapper.registration_to_contact

    self.class.api_write_contact(gitis_contact)

    self
  end

  def assign_gitis_contact(contact)
    self.gitis_contact = contact

    if gitis_uuid != contact.candidate_id
      # using update column to avoid accidentally persisting any other
      # changed state on the candidate

      # This is to handle when a Gitis record gets merged - we request one
      # contactid but the ContactFetcher returns a different contactid

      # if persisted?
      #   update_column :gitis_uuid, contact.contactid
      # else
      #   self.gitis_uuid = contact.contactid
      # end
    end

    gitis_contact
  end

  def attended_bookings
    bookings.includes(:bookings_placement_request).attendance_logged
  end
end
