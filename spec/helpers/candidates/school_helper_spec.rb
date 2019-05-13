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
    before do
      @school = OpenStruct.new(subjects: subjects)

      @formatted = format_school_subjects(@school)
    end

    context 'without subjects' do
      let :subjects do
        []
      end

      it 'should return "Not specified"' do
        expect(@formatted).to eq 'Not specified'
      end
    end

    context 'with subjects' do
      let :subjects do
        [
          OpenStruct.new(id: 1, name: 'First'),
          OpenStruct.new(id: 2, name: 'Second'),
          OpenStruct.new(id: 3, name: 'Third')
        ]
      end

      it 'should be html_safe' do
        expect(@formatted.html_safe?).to be true
      end

      it 'should turn them into a sentence' do
        expect(@formatted).to eq "First, Second, and Third"
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
    context 'with coordinates search' do
      subject do
        double('Coords search',
          latitude: '1',
          longitude: '2',
          location: '',
          location_name: nil,
          query: '')
      end

      it('should say near me') do
        expect(describe_current_search(subject)).to match(/near me/)
      end
    end

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

    before do
      @orig_api_key = ENV['BING_MAPS_KEY']
      ENV['BING_MAPS_KEY'] = '12345'
      @latitude = "53.4782"
      @longitude = "-2.2299"
      @school = OpenStruct.new(
        name: 'Stub School',
        coordinates: OpenStruct.new(latitude: @latitude, longitude: @longitude)
        )
    end

    after { ENV['BING_MAPS_KEY'] = @orig_api_key }

    subject { school_location_map @school }

    it('should return a correct Bing Maps for schools location') do
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
          phases: [1, 3], phase_names: %w{first third})
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
          subjects: [1, 3], subject_names: %w{first third})
      end

      it("should return a nil") do
        expect(school_search_subject_filter_description(subject)).to \
          eq("Placement subjects: <strong>first</strong> and <strong>third</strong>")
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
end
