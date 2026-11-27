require 'rails_helper'

describe WebsiteValidator do
  let(:model) { Struct.new(:errors).new(errors) }
  let(:errors) { instance_double(ActiveModel::Errors) }

  before do
    allow(model).to receive(:errors).and_return(errors)
    allow(errors).to receive(:add)
  end

  context 'when invalid websites' do
    let(:validator) { described_class.new(attributes: { name: 'invalid website' }) }

    ['www.bbc.co.uk', 'huw.edwards@bbc.co.uk', 'huw@bbc', 'bbc', 'http://bbc'].each do |invalid_website|
      it "#{invalid_website} should not be valid" do
        validator.validate_each(model, "website", invalid_website)
        expect(errors).to have_received('add').with('website', 'is not a valid URL')
      end
    end
  end

  context 'when valid websites' do
    let(:validator) { described_class.new(attributes: { name: 'valid website' }) }

    ['https://www.bbc.co.uk', 'http://bbc.co.uk', 'http://news.bbc.co.uk'].each do |valid_website|
      it "#{valid_website} should be valid" do
        validator.validate_each(model, "website", valid_website)
        expect(errors).not_to have_received('add')
      end
    end
  end
end
