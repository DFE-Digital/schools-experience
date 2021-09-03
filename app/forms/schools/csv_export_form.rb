module Schools
  class CsvExportForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    # Multi parameter date fields aren't yet support by ActiveModel so we
    # need to include the support for them from ActiveRecord.
    require "active_record/attribute_assignment"
    include ::ActiveRecord::AttributeAssignment

    attribute :from_date, :date
    attribute :to_date, :date

    validates :from_date, presence: true
    validates :to_date, presence: true
    validates :from_date, timeliness: {
      on_or_before: :to_date,
    }
    validates :to_date, timeliness: {
      on_or_after: :from_date,
    }

    def dates_range
      (from_date.beginning_of_day..to_date.end_of_day)
    end
  end
end
