module Conversions
  module Distance
    METRES_IN_MILE = 1609.344

    module Miles
      module ToMetres
        def self.convert(miles)
          miles * METRES_IN_MILE
        end
      end
    end

    module Metres
      module ToMiles
        def self.convert(metres, precision = 1)
          if precision.nil?
            metres.to_f / METRES_IN_MILE
          elsif precision.zero?
            (metres.to_f / METRES_IN_MILE)
              .to_s(:rounded, precision: 0)
              .to_i
          else
            (metres.to_f / METRES_IN_MILE)
              .to_s(:rounded, precision: precision)
              .to_f
          end
        end
      end
    end
  end
end
