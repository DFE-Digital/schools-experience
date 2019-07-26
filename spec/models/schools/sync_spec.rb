require 'rails_helper'

describe Schools::Sync do
  let(:email_override) { 'test@test.org' }
  subject { described_class.new(email_override: email_override) }

  specify { expect(subject.email_override).to eql(email_override) }
  specify { expect(subject).to respond_to(:sync) }
end
