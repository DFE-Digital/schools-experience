RSpec::Matchers.define :eq_model do |expected|
  match do |actual|
    actual.attributes.except('created_at', 'updated_at') == \
      expected.attributes.except('created_at', 'updated_at')
  end

  failure_message do |actual|
    "expected #{actual.attributes.except('created_at', 'updated_at')} to == #{expected.attributes.except('created_at', 'updated_at')}"
  end
end
