module Candidate
  class School
    include ActiveModel::Model
    include ActiveModelAttributes

    DISTANCES = [
      [1, '1 mile'],
      [3, '3 miles'],
      [5, '5 miles'],
      [10, '10 miles'],
      [15, '15 miles'],
      [20, '20 miles'],
      [25, '25 miles']
    ].freeze

    attribute :query, :string
    attribute :distance, :integer, default: -> {'3'}
    attribute :fees, :boolean
    attribute :subject, :string
    attribute :phase, :string

    def results
      []
    end

    def filtering_results?
      query.present?
    end
  end
end
