module ViewTrackable
  extend ActiveSupport::Concern

  included do
    scope :viewed, -> { where.not viewed_at: nil }
    scope :unviewed, -> { where viewed_at: nil }
  end

  def viewed!
    if viewed_at.nil?
      update!(viewed_at: DateTime.now)
    end
  end

  def viewed?
    viewed_at.present?
  end
end
