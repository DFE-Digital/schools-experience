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

    FEES = [
      ['', 'None'],
      ['30', 'up to £30'],
      ['60', 'up to £60'],
      ['90', 'up to £90']
    ].freeze

    attr_accessor :query
    attr_reader :distance, :subjects, :phases, :max_fee

    class << self
      def fees
        FEES
      end

      def distances
        DISTANCES
      end
    end

    def distance=(d)
      @distance = d.present? ? d.to_i : nil
    end

    def subjects=(s)
      @subjects = Array.wrap(s).map(&:presence).compact.map(&:to_i)
    end

    def phases=(p)
      @phases = Array.wrap(p).map(&:presence).compact.map(&:to_i)
    end

    def max_fee=(mf)
      mf = mf.to_s.strip
      @max_fee = FEES.map(&:first).include?(mf) ? mf : ''
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
