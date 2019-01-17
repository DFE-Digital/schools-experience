module Conversions
  module Distance
    module Miles
      module ToMetres
        def self.convert(miles)
          miles * 1609.344
        end
      end
    end
  end
end
