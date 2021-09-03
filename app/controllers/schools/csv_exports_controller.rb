module Schools
  class CsvExportsController < BaseController
    def show
      @form = CsvExportForm.new
    end

    def create
      @form = CsvExportForm.new(export_params)

      if @form.valid?
        csv = CsvExport.new(current_school, @form.dates_range)

        send_data csv.export,
          type: "text/csv; charset=utf-8; header=present",
          disposition: "attachment; filename=\"#{csv.filename}\""
      else
        render :show
      end
    end

  private

    def export_params
      params.require(:schools_csv_export_form).permit(:from_date, :to_date)
    end
  end
end
