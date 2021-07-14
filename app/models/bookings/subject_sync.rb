module Bookings
  class SubjectSync
    LIMIT = 400
    BLACKLIST = YAML.load_file(Rails.root.join('db', 'data', 'gitis_subject_blacklist.yml')).freeze

    def self.synchronise
      new.synchronise
    end

    def synchronise
      uuids = gitis_subjects.map(&:id)
      assigned = Bookings::Subject.unscoped.where(gitis_uuid: uuids).index_by(&:gitis_uuid)
      unassigned = Bookings::Subject.unscoped.where(gitis_uuid: nil).index_by do |s|
        s.name.to_s.strip.downcase
      end

      Bookings::Subject.transaction do
        gitis_subjects.each do |gitis|
          normalised_name = gitis.value.to_s.strip.downcase
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
      api = GetIntoTeachingApiClient::LookupItemsApi.new
      api.get_teaching_subjects
    end

    def create_or_update_from_gitis!(internal, unassigned, gitis)
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
        name: gitis.value,
        gitis_uuid: gitis.id,
        hidden: BLACKLIST.include?(gitis.value)
    end

    def update_from_gitis!(internal, gitis)
      if internal.name != gitis.value
        internal.update! name: gitis.value
      end
    end

    def assign_gitis_id!(unassigned, gitis)
      unassigned.update! gitis_uuid: gitis.id
    end
  end
end
