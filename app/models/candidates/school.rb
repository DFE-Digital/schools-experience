class Candidates::School
  class << self
    def find(identifier)
      # Note currently using id, will be converted to URN when available
      Bookings::School.find_by!(id: identifier)
    end

    def phases
      Bookings::Phase.all.map do |phase|
        [phase.id, phase.name]
      end
    end

    def subjects
      Bookings::Subject.order(name: :asc).map do |subject|
        [subject.id, subject.name]
      end
    end
  end
end
