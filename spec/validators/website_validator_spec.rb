require 'rails_helper'

describe WebsiteValidator do
  let(:model) { double('model') }
  let(:errors) { double('errors') }

  before do
    allow(model).to receive(:errors).and_return(errors)
  end

  context 'invalid websites' do
    let(:validator) { WebsiteValidator.new(attributes: { name: 'invalid website' }) }

    ['www.bbc.co.uk', 'huw.edwards@bbc.co.uk', 'huw@bbc', 'bbc', 'http://bbc'].each do |invalid_website|
      it "#{invalid_website} should not be valid" do
        expect(errors).to receive('add').with('website', 'is not a valid URL')
        validator.validate_each(model, "website", invalid_website)
      end
    end
  end

  context 'valid websites' do
    let(:validator) { WebsiteValidator.new(attributes: { name: 'valid website' }) }

    ['https://www.bbc.co.uk', 'http://bbc.co.uk', 'http://news.bbc.co.uk'].each do |valid_website|
      it "#{valid_website} should be valid" do
        expect(errors).not_to receive('add')
        validator.validate_each(model, "website", valid_website)
      end
    end
  end
end
