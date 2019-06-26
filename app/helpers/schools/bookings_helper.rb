module Schools::BookingsHelper
  def format_boolean(value)
    value ? "Yes" : "No"
  end

  def format_has_dbs_certificate(has_dbs_certificate)
    if has_dbs_certificate
      'Yes - Candidate says they have DBS certificate (not verified by DfE)'
    else
      'No'
    end
  end
end
