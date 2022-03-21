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

    attr_accessor :query, :location, :latitude, :disability_confident,
                  :longitude, :page, :parking
    attr_reader :distance, :max_fee

    delegate :location_name, :country, :has_coordinates?, :valid?, :errors, to: :school_search
    delegate :whitelisted_urns, :whitelisted_urns?, to: Bookings::SchoolSearch

    class << self
      def fees
        FEES
      end

      def distances
        DISTANCES
      end
    end

    def initialize(*args)
      @distance = 10

      super
    end

    def distance=(dist)
      @distance = dist.present? ? dist.to_i : nil
    end

    def subjects
      @subjects ||= []
    end

    def phases
      @phases ||= []
    end

    def subjects=(subj_ids)
      @subjects = Array.wrap(subj_ids).map(&:presence).compact.map(&:to_i)
    end

    def phases=(phase_ids)
      @phases = Array.wrap(phase_ids).map(&:presence).compact.map(&:to_i)
    end

    def dbs_policies
      @dbs_policies ||= []
    end

    def dbs_policies=(dbs_policy_ids)
      @dbs_policies = Array.wrap(dbs_policy_ids).map(&:presence).compact.map(&:to_i)
    end

    def max_fee=(max_f)
      max_f = max_f.to_s.strip
      @max_fee = FEES.map(&:first).include?(max_f) ? max_f : ''
    end

    def applied_filters
      {
        I18n.t("helpers.fieldset.phases") => {
          phases: phase_filters,
        },
        I18n.t("helpers.fieldset.subjects") => {
          subjects: subject_filters,
        },
        I18n.t("helpers.fieldset.requirements") => {
          dbs_policies: dbs_policy_filters,
          disability_confident: disability_confident_filters,
          parking: parking_filters,
        }
      }
    end

    delegate :results,
       :total_count,
       :phase_count,
       :subject_count,
       :dbs_not_required_count,
       :disability_confident_count,
       :parking_count,
       to: :school_search

    def valid_search?
      query.present? ||
        (location.present? && distance.present?) ||
        (longitude.present? && latitude.present? && distance.present?)
    end

    def filtering_results?
      valid_search?
    end

    def total_results
      results.length
    end

  private

    def subject_filters
      Candidates::School.subjects
        .select { |s| s.first.in?(subjects) }
        .map { |s| { value: s.first, text: s.last } }
    end

    def phase_filters
      Candidates::School.phases
        .select { |p| p.first.in?(phases) }
        .map { |p| { value: p.first, text: p.last } }
    end

    def dbs_policy_filters
      dbs_policies.map do |option|
        policy = Bookings::Profile::DBS_POLICY_CONDITIONS[option]
        policy_text = I18n.t("helpers.candidates.school_search.dbs_policies_filter.options.#{policy}")
        label = I18n.t(
          'helpers.candidates.school_search.dbs_policies_filter.text',
          dbs_policy: policy_text
        )

        { value: option, text: label }
      end
    end

    def disability_confident_filters
      return [] if disability_confident.blank?

      [{
        value: disability_confident,
        text: I18n.t("helpers.candidates.school_search.disability_confident_filter.text")
      }]
    end

    def parking_filters
      return [] if parking.blank?

      [{
        value: parking,
        text: I18n.t("helpers.candidates.school_search.parking_filter.text")
      }]
    end

    def school_search
      @school_search ||= Bookings::SchoolSearch.new(
        query: query,
        location: location_or_coords,
        radius: distance,
        subjects: subjects,
        phases: phases,
        max_fee: max_fee,
        page: page,
        dbs_policies: dbs_policies,
        disability_confident: disability_confident,
        parking: parking
      )
    end

    def location_or_coords
      if latitude.present? && longitude.present?
        { latitude: latitude, longitude: longitude }
      else
        location
      end
    end
  end
end
