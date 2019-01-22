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

    PHASES = [
      ['4-11', 'Primary 4 - 11'],
      ['11-16', 'Secondary 11 - 16'],
      ['16-18', '16 to 18']
    ].freeze

    FEES = [
      ['none', 'None'],
      ['<30', 'up to £30'],
      ['<60', 'up to £60'],
      ['<90', 'up to £90']
    ].freeze

    SUBJECTS = [
      'Art and design', 'Combined science', 'Computer science',
      'Food preparation and nutrition', 'Geography', 'History', 'Music',
      'Physical education', 'Religious studies'
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

    def total_results
      0
    end

  end
end
