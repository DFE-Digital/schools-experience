class Candidates::School
  class << self
    def find(identifier)
      # Note currently using id, will be converted to URN when available
      #Bookings::School.find_by!(urn: identifier)
      Bookings::School.find(identifier)
    end

    def phases
      Bookings::Phase.all.pluck(:id, :name)
    end

    def subjects
      Bookings::Subject.order(name: :asc).pluck(:id, :name)
    end
  end
end
