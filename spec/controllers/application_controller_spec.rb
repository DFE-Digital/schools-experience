require 'rails_helper'

describe ApplicationController, type: :request do
  describe 'X-Robots-Tag' do
    let(:header) { 'X-Robots-Tag' }
    let(:school) { create(:bookings_school) }

    specify "should add 'X-Robots-Tag: all' to crawlable paths" do
      described_class::CRAWLABLE_PATHS.each do |cp|
        head cp
        expect(response.headers[header]).to eql('all')
      end
    end

    specify "should add 'X-Robots-Tag: none' to uncrawlable paths" do
      [
        "/healthcheck.txt",
        candidates_schools_path,
        candidates_school_path(school),
        new_candidates_school_registrations_subject_preference_path(school),
        new_candidates_school_registrations_personal_information_path(school)

      ].each do |cp|
        head cp
        expect(response.headers[header]).to eql('none')
      end
    end
  end
end
