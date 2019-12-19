RSpec::Matchers.define :validate_email_format_of do |attribute|
  VALID_EMAILS = [
    'test@example.com', 'testymctest@gmail.com',
    'test%.mctest@domain.co.uk', ' with@space.com '
  ].freeze

  INVALID_EMAILS = [
    'test.com', 'test@@test.com', 'FFFF', 'test@test',
    'test@test.'
  ].freeze

  match do |model|
    test_with_valid_emails?(model, attribute) &&
      test_with_invalid_emails?(model, attribute)
  end

  failure_message do |model|
    if @mismatch_error_message
      <<~ERRMSG
        Expected #{model.class} to validate that
        :#{attribute} requires a valid email addres, and provide error message
        '#{@expected_message}' but instead the errors were
        #{model.errors[attribute].inspect}
      ERRMSG
    else
      <<~ERRMSG
        Expected #{model.class} to validate that
          :#{attribute} requires a valid email address, but this
          could not be proved whilst testing with address
          '#{@testing_address}'
      ERRMSG
    end
  end

  def with_message(expected)
    @expected_message = expected

    self
  end

private

  def test_with_valid_emails?(model, attribute)
    VALID_EMAILS.all? do |email|
      @testing_address = email

      model.send(:"#{attribute}=", email)
      model.validate

      model.errors.details[attribute].pluck(:error).exclude? :invalid
    end
  end

  def test_with_invalid_emails?(model, attribute)
    INVALID_EMAILS.all? do |email|
      @testing_address = email

      model.send(:"#{attribute}=", email)
      model.validate

      model.errors.details[attribute].pluck(:error).include?(:invalid) &&
        error_message_matches?(model, attribute)
    end
  end

  def error_message_matches?(model, attribute)
    return true unless @expected_message

    return true if model.errors[attribute].include? @expected_message

    @mismatch_error_message = true
    false
  end
end
