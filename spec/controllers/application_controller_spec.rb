require 'rails_helper'

describe ApplicationController, type: :request do
  describe 'X-Robots-Tag' do
    include_context "api healthy"

    let(:header) { 'X-Robots-Tag' }
    let(:school) { create(:bookings_school) }

    specify "should add 'X-Robots-Tag: all' to crawlable paths" do
      described_class::CRAWLABLE_PATHS.each do |cp|
        head cp
        expect(response.headers[header]).to eql('all')
      end
    end

    context 'when school profile paths' do
      let(:disabled_school) { create(:bookings_school, enabled: false) }

      specify "should add 'X-Robots-Tag: all' for enabled schools" do
        head candidates_school_path(school)
        expect(response.headers[header]).to eql('all')
      end

      specify "should add 'X-Robots-Tag: none' for disabled schools" do
        head candidates_school_path(disabled_school)
        expect(response.headers[header]).to eql('none')
      end
    end

    specify "should add 'X-Robots-Tag: none' to uncrawlable paths" do
      [
        "/healthcheck.txt",
        candidates_schools_path,
        new_candidates_school_registrations_background_check_path(school),
        new_candidates_school_registrations_personal_information_path(school)

      ].each do |cp|
        head cp
        expect(response.headers[header]).to eql('none')
      end
    end
  end
end
