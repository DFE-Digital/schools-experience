require 'rails_helper'

describe Bookings::SchoolSearch do
  let(:point_in_manchester) { Bookings::School::GEOFACTORY.point(-2.241, 53.481) }
  let(:point_in_leeds) { Bookings::School::GEOFACTORY.point(-1.548, 53.794) }
  let(:coords_in_manchester) do
    { latitude: point_in_manchester.latitude, longitude: point_in_manchester.longitude }
  end

  let(:geocoder_manchester_search_result) do
    [
      Geocoder::Result::Test.new("latitude" => 53.488, "longitude" => -2.242, name: 'Manchester, UK', address_components: [long_name: "England"]),
      Geocoder::Result::Test.new("latitude" => 53.476, "longitude" => -2.229, name: 'Manchester, UK', address_components: [long_name: "England"])
    ]
  end

  describe 'Validation' do
    subject { described_class.new({}) }
    it { is_expected.to validate_length_of(:location).is_at_least(2) }
    it { is_expected.not_to be_valid }

    context 'with a query parameter' do
      subject { described_class.new({ query: "Somewhere" }) }
      it { is_expected.to be_valid }
    end

    context 'with a non-compliant UTF8 query string' do
      # NB: non-compliant UTF8 query strings are handled elsewhere in the codebase
      subject { described_class.new({ query: "Springfield\xa1" }) }
      it { is_expected.to be_valid }
    end

    context 'with a location hash' do
      subject { described_class.new({ location: { longitude: 1.1, latitude: 2.2 } }) }
      it { is_expected.to be_valid }
    end

    context 'with a location string' do
      subject { described_class.new({ location: "John o'Groats" }) }
      it { is_expected.to be_valid }
    end
  end

  describe '#geolocation' do
    let(:location) { 'Springfield' }

    context 'when Geocoder returns invalid results' do
      let(:expected_error) { Bookings::SchoolSearch::InvalidGeocoderResultError }
      before do
        allow(Geocoder).to receive(:search).and_return('something bad')
      end

      specify 'an error should be raised' do
        expect { Bookings::SchoolSearch.new(query: '', location: 'France') }.to raise_error(expected_error)
      end
    end

    context 'Limiting to United Kingdom' do
      specify 'region should be United Kingdom' do
        expect(described_class::REGION).to eql('United Kingdom')
      end

      context "when a result with name 'United Kingdom' is returned" do
        before do
          allow(Geocoder).to receive(:search).and_return(
            [
              Geocoder::Result::Test.new(
                "latitude" => 53.488,
                "longitude" => -2.242,
                name: 'United Kingdom',
                "address_components" => ["long_name" => "England"]
              )
            ]
          )
        end

        after { Bookings::SchoolSearch.new(location: 'Mumbai') }

        specify "should append the region to the Geocoder query" do
          expect(Geocoder).to receive(:search)
            .with('Mumbai, United Kingdom', params: described_class::GEOCODER_PARAMS)
        end

        specify 'should return an empty result' do
          expect(Rails.logger).to receive(:info).with("No Geocoder results found for Mumbai, United Kingdom (user entered: Mumbai)")
        end
      end
    end
  end

  describe '#results' do
    context 'Search Criteria' do
      before do
        allow(Geocoder).to receive(:search).and_return(geocoder_manchester_search_result)
      end

      let!(:matching_school) do
        create(
          :bookings_school,
          :onboarded,
          name: "Springfield Primary School",
          coordinates: point_in_manchester,
          fee: 10
        )
      end

      let!(:non_matching_school) do
        create(
          :bookings_school,
          name: "Pontefract Primary School",
          coordinates: point_in_leeds,
          fee: 30
        )
      end

      context 'When no conditions are supplied' do
        subject { Bookings::SchoolSearch.new(query: '', location: '').results }
        specify 'results should include no schools' do
          expect(subject.count).to be_zero
        end
      end

      context 'Only enabled schools should be returned' do
        let!(:enabled_school) { create(:bookings_school, :onboarded, coordinates: point_in_manchester) }
        let!(:disabled_school) { create(:bookings_school, :disabled, coordinates: point_in_manchester) }

        subject { Bookings::SchoolSearch.new(location: 'Manchester').results }

        specify 'should return enabled schools' do
          expect(subject).to include(enabled_school)
        end

        specify 'should not return non-enabled schools' do
          expect(subject).not_to include(disabled_school)
        end
      end

      context 'When coodinates are supplied' do
        let!(:coords) { geocoder_manchester_search_result[0] }

        context 'When text and latitude and longitude are supplied' do
          subject do
            Bookings::SchoolSearch.new(query: 'Springfield', location: {
              latitude: coords.latitude, longitude: coords.longitude
            }).results
          end

          specify 'results should include matching records' do
            expect(subject).to include(matching_school)
          end

          specify 'results should not include non-matching records' do
            expect(subject).not_to include(non_matching_school)
          end
        end

        context 'When only lat and lon are supplied' do
          subject do
            Bookings::SchoolSearch.new(
              query: '',
              location: { latitude: coords.latitude, longitude: coords.longitude }
            ).results
          end

          let!(:matching_school) do
            create(:bookings_school, :onboarded, name: "Springfield Primary School")
          end

          specify 'results should include matching records' do
            expect(subject).to include(matching_school)
          end

          specify 'results should not include non-matching records' do
            expect(subject).not_to include(non_matching_school)
          end
        end

        context 'When only latitude is supplied' do
          subject do
            Bookings::SchoolSearch.new(query: '', location: {
              latitude: coords.latitude
            })
          end

          it("should raise error") do
            expect {
              subject.results
            }.to raise_exception(Bookings::SchoolSearch::InvalidCoordinatesError)
          end
        end

        context 'When only longitude is supplied' do
          subject do
            Bookings::SchoolSearch.new(query: '', location: {
              longitude: coords.longitude
            })
          end

          it("should raise error") do
            expect {
              subject.results
            }.to raise_exception(Bookings::SchoolSearch::InvalidCoordinatesError)
          end
        end
      end

      context 'Geocoder' do
        context 'When Geocoder finds a location' do
          before do
            allow(Geocoder).to receive(:search).and_return(geocoder_manchester_search_result)
          end

          context 'When text and location are supplied' do
            subject { Bookings::SchoolSearch.new(query: 'Springfield', location: 'Manchester').results }

            specify 'results should include matching records' do
              expect(subject).to include(matching_school)
            end

            specify 'results should not include non-matching records' do
              expect(subject).not_to include(non_matching_school)
            end
          end

          context 'When only a location is supplied' do
            subject { Bookings::SchoolSearch.new(query: '', location: 'Manchester').results }

            let!(:matching_school) do
              create(:bookings_school, :onboarded, name: "Springfield Primary School")
            end

            specify 'results should include matching records' do
              expect(subject).to include(matching_school)
            end

            specify 'results should not include non-matching records' do
              expect(subject).not_to include(non_matching_school)
            end
          end
        end

        context 'When Geocoder finds no location' do
          context 'When the query does not match a school' do
            before do
              allow(Geocoder).to receive(:search).and_return([])
            end

            subject { Bookings::SchoolSearch.new(location: 'Chippewa, Michigan').results }

            specify 'results should include all schools' do
              expect(subject.size).to be_zero
            end
          end
        end

        context 'When Geocoder returns an invalid location' do
          context 'When the query matches a school' do
            before do
              allow(Geocoder).to receive(:search).and_return("ABC123")
            end

            subject { Bookings::SchoolSearch.new(location: 'Madrid') }

            specify 'should fail with a InvalidGeocoderResultError' do
              expect { subject.results }.to raise_error(Bookings::SchoolSearch::InvalidGeocoderResultError)
            end
          end
        end
      end

      context 'Filtering' do
        # subjects
        let(:maths) { Bookings::Subject.find_by! name: "Maths" }
        let(:physics) { Bookings::Subject.find_by! name: "Physics" }
        # phases
        let(:college) { create(:bookings_phase, name: "College") }
        let(:secondary) { create(:bookings_phase, name: "Secondary") }
        # DBS Policies
        let!(:dbs_required) { create(:bookings_profile, dbs_policy_conditions: 'required') }
        let!(:dbs_inschool) { create(:bookings_profile, dbs_policy_conditions: 'inschool') }
        let!(:dbs_notrequired) { create(:bookings_profile, dbs_policy_conditions: 'notrequired') }

        context 'Filtering on subjects' do
          before do
            matching_school.subjects << maths
            non_matching_school.subjects << physics
          end

          subject { Bookings::SchoolSearch.new(query: '', location: coords_in_manchester, subjects: maths.id).results }

          specify 'should return matching results' do
            expect(subject).to include(matching_school)
          end

          specify 'should omit non-matching results' do
            expect(subject).not_to include(non_matching_school)
          end
        end

        context 'Filtering on phases' do
          before do
            matching_school.phases << college
            non_matching_school.phases << secondary
          end

          subject { Bookings::SchoolSearch.new(query: '', location: coords_in_manchester, phases: college.id).results }

          specify 'should return matching results' do
            expect(subject).to include(matching_school)
          end

          specify 'should omit non-matching results' do
            expect(subject).not_to include(non_matching_school)
          end
        end

        context 'Filtering on fees' do
          subject { Bookings::SchoolSearch.new(query: '', location: coords_in_manchester, max_fee: 20).results }

          specify 'should return matching results' do
            expect(subject).to include(matching_school)
          end

          specify 'should omit non-matching results' do
            expect(subject).not_to include(non_matching_school)
          end
        end

        context 'Filtering on dbs' do
          let!(:another_matching_school) do
            create(
              :bookings_school,
              name: "Moore Primary School",
              coordinates: point_in_manchester,
              fee: 10
            )
          end

          before do
            matching_school.profile = dbs_notrequired
            another_matching_school.profile = dbs_inschool
            non_matching_school.profile = dbs_required
          end

          subject { Bookings::SchoolSearch.new(query: '', location: coords_in_manchester, dbs_policies: [2]).results }

          specify 'should return both schools requiring DBS for in school or not requiring DBS at all' do
            expect(subject).to include(matching_school, another_matching_school)
          end

          specify 'should omit schools requiring DBS' do
            expect(subject).not_to include(non_matching_school)
          end
        end

        context 'Filtering on disability confident' do
          before do
            create(:bookings_profile, :without_supports_access_needs, school: non_matching_school)
          end

          subject { Bookings::SchoolSearch.new(query: '', location: coords_in_manchester, disability_confident: '1').results }

          specify 'should return matching results' do
            expect(subject).to include(matching_school)
          end

          specify 'should omit non-matching results' do
            expect(subject).not_to include(non_matching_school)
          end
        end

        context 'Filtering on parking' do
          subject { Bookings::SchoolSearch.new(query: '', location: coords_in_manchester, parking: '1').results }

          specify 'should return matching results' do
            matching_school.profile.update(parking_provided: true)

            expect(subject).to include(matching_school)
          end

          specify 'should omit non-matching results' do
            expect(subject).not_to include(non_matching_school)
          end
        end
      end

      context 'Chaining' do
        let(:secondary) { create(:bookings_phase, name: "Secondary") }
        let(:physics) { Bookings::Subject.find_by! name: "Physics" }

        before do
          allow(Geocoder).to receive(:search).and_return(geocoder_manchester_search_result)
        end

        before do
          matching_school.phases << secondary
          matching_school.subjects << physics
        end

        subject do
          Bookings::SchoolSearch.new(
            query: 'Springf',
            location: 'Cheetham Hill',
            subjects: physics,
            phases: secondary,
            max_fee: 20
          ).results
        end

        specify 'should allow all search options and filters to work in conjunction' do
          expect(subject).to include(matching_school)
        end
      end
    end

    context 'Ordering' do
      context 'Geographic ordering' do
        let(:point_in_manchester) { Bookings::School::GEOFACTORY.point(-2.241, 53.481) }
        let(:point_in_leeds) { Bookings::School::GEOFACTORY.point(-1.548, 53.794) }
        let(:point_in_glasgow) { Bookings::School::GEOFACTORY.point(-4.219, 55.859) }
        let(:point_in_york) { Bookings::School::GEOFACTORY.point(-1.095, 53.597) }

        let!(:glasgow_school) { create(:bookings_school, :onboarded, name: "Glasgow", coordinates: point_in_glasgow) }
        let!(:york_school) { create(:bookings_school, :onboarded, name: "York", coordinates: point_in_york) }
        let!(:mcr_school) { create(:bookings_school, :onboarded, name: "Manchester", coordinates: point_in_manchester) }
        let!(:leeds_school) { create(:bookings_school, :onboarded, :onboarded, name: "Leeds", coordinates: point_in_leeds) }

        before do
          allow(Geocoder).to receive(:search).and_return(geocoder_manchester_search_result)
        end

        subject do
          Bookings::SchoolSearch.new(query: '', location: 'Cheetham Hill', radius: 500).results
        end

        specify 'schools should be ordered by distance, near to far' do
          expect(subject.map(&:name)).to eql([mcr_school, leeds_school, york_school, glasgow_school].map(&:name))
        end
      end
    end

    context 'Other scopes/criteria' do
      let(:phases) { create_list(:bookings_phase, 2).map(&:id) }
      let(:subjects) { create_list(:bookings_subject, 2).map(&:id) }
      let(:max_fee) { 20 }

      after do
        Bookings::SchoolSearch.new(
          location: 'Bury',
          phases: phases,
          subjects: subjects,
          max_fee: max_fee
        ).results
      end

      specify 'should apply the :enabled scope' do
        expect(Bookings::School).to receive(:enabled).and_call_original
      end

      specify 'should apply the :onboarded scope' do
        expect(Bookings::School).to receive(:enabled).and_call_original
      end

      specify 'should apply the :with_availability scope' do
        expect(Bookings::School).to receive(:enabled).and_call_original
      end

      specify 'should apply the :at_phases scope with supplied phases' do
        expect(Bookings::School).to receive(:at_phases).with(phases).and_call_original
      end

      specify 'should apply the :that_provide scope with supplied subjects' do
        expect(Bookings::School).to receive(:that_provide).with(subjects).and_call_original
      end

      specify 'should apply the :costing_upto scope with max fee' do
        expect(Bookings::School).to receive(:costing_upto).with(max_fee).and_call_original
      end
    end
  end

  describe "#phase_count" do
    let!(:early_years) { create(:bookings_phase, :early_years) }
    let!(:primary) { create(:bookings_phase, :primary) }
    let!(:secondary) { create(:bookings_phase, :secondary) }
    let!(:college) { create(:bookings_phase, :college) }

    let(:instance) { described_class.new(location: "Bury", radius: 50) }

    it { expect(instance.phase_count(-1)).to eq(0) }

    context "when there are schools with the given phase_id in the result set" do
      before do
        create_list(:bookings_school, 4, :onboarded, :early_years)
        create_list(:bookings_school, 3, :onboarded, :primary)
        create_list(:bookings_school, 2, :onboarded, :secondary)
        create_list(:bookings_school, 1, :onboarded, :college)

        outside_search_coordinates = Bookings::School::GEOFACTORY.point(-1.148, 52.794)
        create(:bookings_school, :onboarded, :early_years, coordinates: outside_search_coordinates)
        create(:bookings_school, :onboarded, :secondary, coordinates: outside_search_coordinates)
      end

      it { expect(instance.phase_count(early_years.id)).to eq(4) }
      it { expect(instance.phase_count(primary.id)).to eq(3) }
      it { expect(instance.phase_count(secondary.id)).to eq(2) }
      it { expect(instance.phase_count(college.id)).to eq(1) }
    end
  end

  describe "#subject_count" do
    let(:maths) { Bookings::Subject.find_by(name: "Maths") }

    let(:instance) { described_class.new(location: "Bury", radius: 50) }

    it { expect(instance.subject_count(-1)).to eq(0) }

    context "when there are schools with the given subject_id in the result set" do
      before do
        create_list(:bookings_school, 4, :onboarded).each do |s|
          create(:bookings_schools_subject, bookings_school: s, bookings_subject: maths)
        end

        outside_search_coordinates = Bookings::School::GEOFACTORY.point(-1.148, 52.794)
        outside_school = create(:bookings_school, :onboarded, coordinates: outside_search_coordinates)
        create(:bookings_schools_subject, bookings_school: outside_school, bookings_subject: maths)
      end

      it { expect(instance.subject_count(maths.id)).to eq(4) }
    end
  end

  describe "#dbs_not_required_count" do
    let(:instance) { described_class.new(location: "Bury", radius: 50) }

    it { expect(instance.dbs_not_required_count).to eq(0) }

    context "when there are schools that do not require a dbs check in the result set" do
      before do
        create_list(:bookings_school, 2, :onboarded, profile: create(:bookings_profile, dbs_policy_conditions: "notrequired"))
        create_list(:bookings_school, 2, :onboarded, profile: create(:bookings_profile, dbs_policy_conditions: "inschool"))

        create(:bookings_school, :onboarded, profile: create(:bookings_profile, dbs_policy_conditions: "required"))
        outside_search_coordinates = Bookings::School::GEOFACTORY.point(-1.148, 52.794)
        create(:bookings_school, :onboarded, profile: create(:bookings_profile, dbs_policy_conditions: "notrequired"), coordinates: outside_search_coordinates)
      end

      it { expect(instance.dbs_not_required_count).to eq(2) }
    end
  end

  describe "#disability_confident_count" do
    let(:instance) { described_class.new(location: "Bury", radius: 50) }

    it { expect(instance.disability_confident_count).to eq(0) }

    context "when there are schools that do not require a dbs check in the result set" do
      before do
        create_list(:bookings_school, 2, :onboarded)

        create(:bookings_school, :onboarded, profile: create(:bookings_profile, disability_confident: false))
        outside_search_coordinates = Bookings::School::GEOFACTORY.point(-1.148, 52.794)
        create(:bookings_school, :onboarded, coordinates: outside_search_coordinates)
      end

      it { expect(instance.disability_confident_count).to eq(2) }
    end
  end

  describe "#parking_count" do
    let(:instance) { described_class.new(location: "Bury", radius: 50) }

    it { expect(instance.disability_confident_count).to eq(0) }

    context "when there are schools that do not require a dbs check in the result set" do
      before do
        create_list(:bookings_school, 2, :onboarded, profile: create(:bookings_profile, parking_provided: true))

        create(:bookings_school, :onboarded)
        outside_search_coordinates = Bookings::School::GEOFACTORY.point(-1.148, 52.794)
        create(:bookings_school, :onboarded, coordinates: outside_search_coordinates)
      end

      it { expect(instance.disability_confident_count).to eq(2) }
    end
  end

  describe '#total_count' do
    let!(:matching_schools) do
      create_list(:bookings_school, 8, :onboarded)
    end

    let!(:non_matching_school) do
      create(:bookings_school, :onboarded, coordinates: Bookings::School::GEOFACTORY.point(-1.148, 52.794))
    end

    specify 'total count should match the number of matching schools' do
      expect(Bookings::SchoolSearch.new(location: "Bury", radius: 50).total_count).to eql(matching_schools.length)
    end

    context 'Saving results' do
      let(:location) { "Bury" }
      let(:query) { nil }
      let(:instance) { Bookings::SchoolSearch.new(location: location, query: query, radius: 50) }

      subject { instance.tap(&:total_count) }

      specify 'should save the record' do
        expect(subject).to be_persisted
      end

      specify 'should save the total number of results' do
        expect(subject.number_of_results).to eql(matching_schools.length)
      end

      context "when the query contains an unexpected ASCII byte sequence" do
        let(:query) { "Springfield\xa1" }

        before do
          allow(Rails.logger).to receive(:error)
        end

        it "logs an error and recovers by removing the unexpected character" do
          expect(subject.query).to eq("Springfield")
          expect(Rails.logger).to have_received(:error).with({
            error: an_instance_of(ActiveRecord::StatementInvalid),
            details: { location: location, query: query }
          })
        end
      end

      context 'filtering' do
        let(:phases) { [1, 2, 3] }
        let(:subjects) { [2, 3, 4] }
        let(:max_fee) { 30 }
        let(:location) { "Birmingham" }
        subject do
          Bookings::SchoolSearch.new(
            location: location,
            phases: phases,
            subjects: subjects,
            max_fee: max_fee
          )
        end

        specify 'should record all search parameters' do
          expect(subject.phases).to eql(phases)
          expect(subject.subjects).to eql(subjects)
          expect(subject.max_fee).to eql(max_fee)
          expect(subject.location).to eql(location)
        end
      end
    end
  end

  describe "#country" do
    subject { Bookings::SchoolSearch.new(location: "Test") }

    let(:scotland_search_result) do
      [
        Geocoder::Result::Test.new("address_components" => [{ "long_name" => "Scotland", "short_name" => "Scotland", "types" => %w[administrative_area_level_1 political] }], "latitude" => 53.488, "longitude" => -2.242)
      ]
    end
    let(:wales_search_result) do
      [
        Geocoder::Result::Test.new("address_components" => [{ "long_name" => "Wales", "short_name" => "Wales", "types" => %w[administrative_area_level_1 political] }], "latitude" => 53.488, "longitude" => -2.242)
      ]
    end
    let(:northern_ireland_search_result) do
      [
        Geocoder::Result::Test.new("address_components" => [{ "long_name" => "Northern Ireland", "short_name" => "Northern Ireland", "types" => %w[administrative_area_level_1 political] }], "latitude" => 53.488, "longitude" => -2.242)
      ]
    end

    context "when search result includes Scotland" do
      before { allow(Geocoder).to receive(:search).and_return(scotland_search_result) }

      it "returns Scotland" do
        expect(subject.country.name).to eq "Scotland"
      end
    end

    context "when search result includes Wales" do
      before { allow(Geocoder).to receive(:search).and_return(wales_search_result) }

      it "returns Scotland" do
        expect(subject.country.name).to eq "Wales"
      end
    end

    context "when search result includes Northern Ireland" do
      before { allow(Geocoder).to receive(:search).and_return(northern_ireland_search_result) }

      it "returns Scotland" do
        expect(subject.country.name).to eq "Northern Ireland"
      end
    end
  end

  describe '#has_coordinates?' do
    subject { Bookings::SchoolSearch.new(location: "Bury") }

    context 'when coordinates are present' do
      before { allow(subject).to receive(:coordinates).and_return(point_in_leeds) }
      it { is_expected.to have_coordinates }
    end

    context 'when coordinates are absent' do
      before { allow(subject).to receive(:coordinates).and_return([]) }
      it { is_expected.not_to have_coordinates }
    end
  end

  context 'whitelisted_urns' do
    let(:whitelist) { '1' }
    let(:school_search) { described_class.new(location: "Bury", radius: 10) }
    subject { school_search }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('CANDIDATE_URN_WHITELIST').and_return(whitelist)
    end

    it { is_expected.to have_attributes whitelisted_urns?: true }
    it { is_expected.to have_attributes whitelisted_urns: [1] }
    it { is_expected.to have_attributes radius: 1000 }

    context 'searching' do
      let(:schools) { create_list :bookings_school, 3, :onboarded }
      let(:school_urns) { schools.map(&:urn) }
      let(:whitelist) { school_urns.slice(0, 2).join(' ') }
      subject { school_search.results.map(&:urn) }
      it { is_expected.to include school_urns[0] }
      it { is_expected.to include school_urns[1] }
      it { is_expected.not_to include school_urns[2] }
    end

    context 'without whitelist' do
      let(:whitelist) { '' }
      it { is_expected.to have_attributes whitelisted_urns?: false }
      it { is_expected.to have_attributes whitelisted_urns: [] }
      it { is_expected.to have_attributes radius: 10 }
    end
  end
end
