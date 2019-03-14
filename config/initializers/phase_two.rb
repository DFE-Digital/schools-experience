if %w(test development).include?(Rails.env) || ENV['PHASE_TWO'].present?
  PHASE_TWO = true
else
  PHASE_TWO = false
end
