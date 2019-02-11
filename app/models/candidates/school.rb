class Candidates::School
  class << self
    def find(identifier)
      Bookings::School.find_by!(urn: identifier)
    end

    def phases
      Bookings::Phase.all.pluck(:id, :name)
    end

    def subjects
      Bookings::Subject.order(name: :asc).pluck(:id, :name)
    end
  end
end
