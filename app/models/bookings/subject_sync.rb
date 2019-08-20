module Bookings
  class SubjectSync
    LIMIT = 400

    def self.synchronise(crm)
      new(crm).synchronise
    end

    def initialize(crm)
      @crm = crm
    end

    def synchronise
      uuids = gitis_subjects.map(&:dfe_teachingsubjectlistid)
      assigned = Bookings::Subject.where(gitis_uuid: uuids).index_by(&:gitis_uuid)
      unassigned = Bookings::Subject.where(gitis_uuid: nil).index_by do |s|
        s.name.to_s.strip.downcase
      end

      Bookings::Subject.transaction do
        gitis_subjects.each do |gitis|
          normalised_name = gitis.dfe_name.to_s.strip.downcase
          create_or_update_from_gitis! assigned[gitis.id], unassigned[normalised_name], gitis
        end
      end
    end

    class TooManySubjects < RuntimeError; end

  private

    def gitis_subjects
      @gitis_subjects ||= fetch_gitis_subjects.tap do |subjs|
        # Likely there are more subjects in Gitis than we are retrieving
        raise TooManySubjects if subjs.length >= LIMIT
      end
    end

    def fetch_gitis_subjects
      @crm.fetch(Bookings::Gitis::TeachingSubject, limit: LIMIT)
    end

    def create_or_update_from_gitis! internal, unassigned, gitis
      if internal
        update_from_gitis! internal, gitis
      elsif unassigned
        assign_gitis_id! unassigned, gitis
      else
        create_from_gitis! gitis
      end
    end

    def create_from_gitis!(gitis)
      Bookings::Subject.create! \
        name: gitis.dfe_name,
        gitis_uuid: gitis.id
    end

    def update_from_gitis!(internal, gitis)
      if internal.name != gitis.dfe_name
        internal.update! name: gitis.dfe_name
      end
    end

    def assign_gitis_id!(unassigned, gitis)
      unassigned.update! gitis_uuid: gitis.id
    end
  end
end
