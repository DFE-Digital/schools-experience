RSpec::Matchers.define :validate_email_format_of do |attribute|
  VALID_EMAILS = [
    'test@example.com', 'testymctest@gmail.com',
    'test%.mctest@domain.co.uk', ' with@space.com '
  ].freeze

  INVALID_EMAILS = [
    'test.com', 'test@@test.com', 'FFFF', 'test@test',
    'test@test.'
  ].freeze

  BLANK_EMAILS = ['', ' ', '   '].freeze

  match do |model|
    test_with_valid_emails?(model, attribute) &&
      test_with_invalid_emails?(model, attribute) &&
      test_with_blank_emails?(model, attribute)
  end

  failure_message do |model|
    <<~ERRMSG
      Expected #{model.class} to validate that
        :#{attribute} requires a valid email address, but this
        could not be proved whilst testing with address
        '#{@testing_address}'
    ERRMSG
  end

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

      model.errors.details[attribute].pluck(:error).include? :invalid
    end
  end

  def test_with_blank_emails?(model, attribute)
    BLANK_EMAILS.all? do |email|
      @testing_address = email

      model.send(:"#{attribute}=", email)
      model.validate

      model.errors.details[attribute].pluck(:error).include? :blank
    end
  end
end
