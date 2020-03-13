module Bookings
  module Gitis
    class FilterBuilder
      def initialize(*args)
        @constraint = serialize(*args)
      end

      def and(*args)
        @constraint = "#{self} and #{serialize(*args)}"
        self
      end

      def or(*args)
        @constraint = "#{self} or #{serialize(*args)}"
        self
      end

      def to_s
        @constraint
      end

    private

      def serialize(attribute_or_filter, value = nil, operator = 'eq')
        if attribute_or_filter.is_a? FilterBuilder
          "(#{attribute_or_filter})"
        else
          "#{attribute_or_filter} #{operator} #{serialize_value value}"
        end
      end

      def serialize_value(value)
        case value
        when String
          "'#{value}'"
        when nil
          'null'
        else
          value.to_s
        end
      end
    end
  end
end
