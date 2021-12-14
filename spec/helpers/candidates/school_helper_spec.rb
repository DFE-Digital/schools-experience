require 'rails_helper'

RSpec.describe Candidates::SchoolHelper, type: :helper do
  context '.format_school_address' do
    before do
      @school = OpenStruct.new(
        address_1: nil,
        address_2: 'Picadilly Gate',
        address_3: '',
        town: 'Manchester',
        county: 'Manchester',
        postcode: 'MA1 1AM'
      )

      @formatted = format_school_address(@school)
    end

    it 'should be html_safe' do
      expect(@formatted.html_safe?).to be true
    end

    it 'should concatenate non blank fields' do
      expect(@formatted).to eq "Picadilly Gate, Manchester, Manchester, MA1 1AM"
    end
  end

  context '.format_school_subjects' do
    let(:school) { create(:bookings_school) }
    let(:output) { format_school_subjects(school) }

    context 'without subjects' do
      let :subjects do
        []
      end

      it 'should return "Not specified"' do
        expect(output).to eq 'Not specified'
      end
    end

    context 'with subjects' do
      let(:subject_1) { create(:bookings_subject, name: 'First') }
      let(:subject_2) { create(:bookings_subject, name: 'Second') }
      let(:subject_3) { create(:bookings_subject, name: 'Third') }

      let!(:subjects) { [subject_1, subject_2, subject_3] }
      before do
        school.subjects << subjects
      end

      it 'should be html_safe' do
        expect(output.html_safe?).to be true
      end

      it 'should turn them into a sentence' do
        expect(output).to eq "First, Second, and Third"
      end

      context 'highlighting filter matches' do
        before do
          allow(self).to receive(:filtered_subject_ids).and_return([subject_2.id])
        end

        it 'should bolden matched subjects' do
          expect(output).to have_css('strong', text: subject_2.name)
        end

        it 'should include but not bolden unmatched subjects' do
          [subject_1, subject_3].each do |subj|
            expect(output).to have_content(subj.name)
            expect(output).not_to have_css('strong', text: subj.name)
          end
        end
      end
    end
  end

  context '.format_school_phases' do
    before do
      @school = OpenStruct.new(
        phases: [
          OpenStruct.new(id: 1, name: 'First'),
          OpenStruct.new(id: 2, name: 'Second'),
          OpenStruct.new(id: 3, name: 'Third')
        ]
      )
    end

    let(:formatted) do
      format_school_phases(@school)
    end

    let(:parsed) { Nokogiri.parse(formatted) }

    it 'should be html_safe' do
      expect(formatted.html_safe?).to be true
    end

    it 'should turn them into a list' do
      expect(parsed.css('ul.govuk-list > li').map(&:text)).to eql(@school.phases.map(&:name))
    end
  end

  context '.describe_current_search' do
    context 'with location search' do
      context 'and name supplied by search' do
        subject do
          double('Location search',
            latitude: '',
            longitude: '',
            location: 'Manchester',
            location_name: 'Manchester, United Kingdom',
            query: '')
        end

        it('should say near Manchester') do
          expect(describe_current_search(subject)).to match(/near Manchester, United Kingdom/)
        end
      end

      context 'without name supplied by search' do
        subject do
          double('Location search',
            latitude: '',
            longitude: '',
            location: 'Manchester',
            location_name: nil,
            query: '')
        end

        it('should say near Manchester') do
          expect(describe_current_search(subject)).to match(/near Manchester$/)
        end
      end
    end

    context 'with query search' do
      subject do
        double('Text search',
          latitude: '',
          longitude: '',
          location: '',
          location_name: nil,
          query: 'special school')
      end

      it('should say matching special school') do
        expect(describe_current_search(subject)).to \
          match(/matching special school/i)
      end
    end
  end

  context '.school_location_map' do
    include Candidates::MapsHelper
    include ActionController::Base::HelperMethods

    before do
      allow(Rails.application.config.x).to receive(:google_maps_key) { '12345' }
      @latitude = "53.4782"
      @longitude = "-2.2299"
      @school = OpenStruct.new(
        name: 'Stub School',
        coordinates: OpenStruct.new(latitude: @latitude, longitude: @longitude)
      )
    end

    subject { school_location_map @school }

    it('should return a correct Google Maps for schools location') do
      expect(subject).to match(/<img /)
      expect(subject).to match("#{@latitude}%2C#{@longitude}")
    end
  end

  context '.school_search_phase_filter_description' do
    context 'with no subjects' do
      subject do
        double('Bookings::SchoolSearch',
          phases: [], phase_names: [])
      end

      it("should return a nil") do
        expect(school_search_phase_filter_description(subject)).to be_nil
      end
    end

    context 'with subject filters' do
      subject do
        double('Bookings::SchoolSearch',
          phases: [1, 3], phase_names: %w[first third])
      end

      it("should return a nil") do
        expect(school_search_phase_filter_description(subject)).to \
          eq("Education phases: <strong>first</strong> and <strong>third</strong>")
      end
    end
  end

  context '.school_search_subject_filter' do
    context 'with no subjects' do
      subject do
        double('Bookings::SchoolSearch',
          subjects: [], subject_names: [])
      end

      it("should return a nil") do
        expect(school_search_subject_filter_description(subject)).to be_nil
      end
    end

    context 'with subject filters' do
      subject do
        double('Bookings::SchoolSearch',
          subjects: [1, 3], subject_names: %w[first third])
      end

      it("should return a nil") do
        expect(school_search_subject_filter_description(subject)).to \
          eq("Placement subjects: <strong>first</strong> and <strong>third</strong>")
      end
    end
  end

  context '.school_search_dbs_policies_filter_description' do
    context 'with no selections' do
      subject do
        double('Bookings::SchoolSearch',
          dbs_policies: [], dbs_policies_names: [])
      end

      it("should return a nil") do
        expect(school_search_dbs_policies_filter_description(subject)).to be_nil
      end
    end

    context 'with dbs policies filters' do
      subject do
        double('Bookings::SchoolSearch',
          dbs_policies: [2], dbs_policies_names: ['Not required'])
      end

      it("should return a nil") do
        expect(school_search_dbs_policies_filter_description(subject)).to \
          eq("DBS check: <strong>Not required</strong>")
      end
    end
  end

  context '.school_search_disability_confident_filter_description' do
    context 'when the disability confident filter is not selected' do
      subject do
        double('Bookings::SchoolSearch', disability_confident: nil)
      end

      it("should return a nil") do
        expect(school_search_disability_confident_filter_description(subject)).to be_nil
      end
    end

    context 'when the disability confident filter is selected' do
      subject do
        double('Bookings::SchoolSearch', disability_confident: '1')
      end

      it("should return yes") do
        expect(school_search_disability_confident_filter_description(subject)).to \
          eq("Disability Confident schools: <strong>Yes</strong>")
      end
    end
  end

  describe '#cleanup_school_url' do
    context 'with blank url' do
      subject { cleanup_school_url(' ') }
      it('should return a same page url') { expect(subject).to eq('#') }
    end

    context 'with protocol present' do
      subject { cleanup_school_url('https://www.gov.uk') }
      it('should return as is') { expect(subject).to eq('https://www.gov.uk') }
    end

    context 'with email mailto link' do
      subject { cleanup_school_url('mailto:me@you.com') }
      it('should return as is') { expect(subject).to eq('mailto:me@you.com') }
    end

    context 'with email address' do
      subject { cleanup_school_url('me@you.com') }
      it('should add mailto protocol') { expect(subject).to eq('mailto:me@you.com') }
    end

    context 'with no protocol' do
      subject { cleanup_school_url('www.gov.uk') }
      it('should use http protocol') { expect(subject).to eq('http://www.gov.uk') }
    end
  end

  describe '#dlist_item' do
    subject do
      dlist_item('list item', id: 'testid') { 'test123' }
    end

    it { is_expected.to have_css('div.govuk-summary-list__row#testid') }
    it { is_expected.to have_css('div > dt') }
    it { is_expected.to have_css('div > dd', text: 'test123') }
  end

  describe '#content_or_msg' do
    context 'with content' do
      subject { content_or_msg('<p>foobar</p>', 'no content') }
      it { is_expected.to have_css('p', text: 'foobar') }
    end

    context 'without content but text msg' do
      subject { content_or_msg('', 'no content') }
      it { is_expected.to have_css('em', text: 'no content') }
    end

    context 'without content but block msg' do
      subject { content_or_msg('') { '<b>no content</b>' } }
      it { is_expected.to have_css('b', text: 'no content') }
    end
  end

  describe '#split to list' do
    specify 'should return nil when nil passed in' do
      expect(split_to_list(nil)).to be_nil
    end

    specify 'should return nil when empty string passed in' do
      expect(split_to_list('')).to be_nil
    end

    context 'splitting up items into a HTML list' do
      let(:content) do
        <<~CONTENT
          The good,
          the bad
          and the ugly
        CONTENT
      end

      subject { split_to_list content }

      specify 'should create a list with the correct number of entries' do
        is_expected.to have_css('ul.govuk-list--bullet > li', count: 3)
      end
    end

    context 'dealing with blank lines' do
      let(:content) do
        <<~CONTENT
          The good,

          and the ugly
        CONTENT
      end

      subject { split_to_list content }

      specify 'should create a list with the correct number of entries' do
        is_expected.to have_css('ul.govuk-list--bullet > li', count: 2)
      end
    end
  end

  describe "#format_school_placement_locations" do
    subject { format_school_placement_locations school }

    context "for school with virtual placements" do
      let(:school) { create(:bookings_placement_date, virtual: true).bookings_school }

      it { is_expected.to have_css ".govuk-tag", text: "Virtual" }
      it { is_expected.not_to have_css ".govuk-tag", text: "In school" }
    end

    context "for school with inschool placements" do
      let(:school) { create(:bookings_placement_date, virtual: false).bookings_school }

      it { is_expected.not_to have_css ".govuk-tag", text: "Virtual" }
      it { is_expected.to have_css ".govuk-tag", text: "In school" }
    end

    context "for school with both virtual and inschool placements" do
      let :school do
        create(:bookings_placement_date, virtual: true).bookings_school.tap do |school|
          create :bookings_placement_date, virtual: false, bookings_school: school
        end
      end

      it { is_expected.to have_css ".govuk-tag", text: "Virtual" }
      it { is_expected.to have_css ".govuk-tag", text: "In school" }
    end
  end
end
