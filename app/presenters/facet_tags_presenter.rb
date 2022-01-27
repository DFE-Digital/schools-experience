class FacetTagsPresenter
  def initialize(applied_filters)
    @applied_filters = applied_filters
  end

  def applied_filters
    @applied_filters.transform_values { |keyed_filters|
      keyed_filters.reduce([]) do |acc, (key, filters)|
        acc += filters.each_with_index do |filter, index|
          filter[:key] = key.to_s.dasherize
          if index.zero?
            filter[:preposition] = :and unless acc.empty?
          else
            filter[:preposition] = :or
          end
        end
      end
    }.compact_blank
  end
end
