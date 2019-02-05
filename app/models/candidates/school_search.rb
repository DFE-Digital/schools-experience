module Candidates
  class SchoolSearch
    include ActiveModel::Model

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
      %w{none None},
      ['<30', 'up to £30'],
      ['<60', 'up to £60'],
      ['<90', 'up to £90']
    ].freeze

    SUBJECTS = [
      'Art and design', 'Combined science', 'Computer science',
      'Food preparation and nutrition', 'Geography', 'History', 'Music',
      'Physical education', 'Religious studies'
    ].freeze

    attr_accessor :query
    attr_writer :distance
    attr_accessor :fees, :subject, :phases

    class << self
      def fees
        FEES
      end

      def subjects
        SUBJECTS
      end

      def phases
        PHASES
      end

      def distances
        DISTANCES
      end
    end

    def distance
      @distance.to_i
    end

    def results
      school_search.results
    end

    def filtering_results?
      query.present?
    end

    def total_results
      0
    end

  private

    def school_search
      @school_search ||= Bookings::SchoolSearch.new(
        query,
        radius: distance
      )
    end
  end
end
