ActiveRecord::RecordInvalid.class_eval do
  def initialize(record = nil)
    if record
      @record = record
      errors = @record.errors.to_hash.inspect
      message = I18n.t(:"#{@record.class.i18n_scope}.errors.messages.record_invalid", errors: errors, default: :"errors.messages.record_invalid")
    else
      message = "Record invalid"
    end

    super(message)
  end
end
