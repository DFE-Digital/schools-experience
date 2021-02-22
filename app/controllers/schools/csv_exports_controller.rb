module Schools
  class CsvExportsController < BaseController
    def show; end

    def create
      @csv = CsvExport.new(current_school)

      send_data @csv.export,
        type: "text/csv; charset=utf-8; header=present",
        disposition: "attachment; filename=\"#{@csv.filename}\""
    end
  end
end
