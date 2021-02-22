module AcademicYear
  def self.start_for_date(date)
    if date.month >= 9 # has the new academic year begun yet
      date.change(month: 9, day: 1).at_beginning_of_day
    else
      date.change(year: (date.year - 1), month: 9, day: 1).at_beginning_of_day
    end
  end
end
