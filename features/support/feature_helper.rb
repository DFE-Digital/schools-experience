def delay_page_load
  if ENV['CUC_DRIVER'].present? || ENV['CUC_PAGE_DELAY'].present?
    sleep Integer(ENV.fetch('CUC_PAGE_DELAY', 0))
  end
end

def onboard_schools(schools)
  schools.each do |s|
    FactoryBot.create(:bookings_profile, school: s)
  end
end
