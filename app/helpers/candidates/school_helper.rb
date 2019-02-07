module Candidates::SchoolHelper
  def format_school_address(school)
    safe_join([
      school.address_1.presence,
      school.address_2.presence,
      school.address_3.presence,
      school.town.presence,
      school.county.presence,
      school.postcode.presence,
    ].compact, ", ")
  end
end
