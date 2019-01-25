require 'rails_helper'

describe Bookings::SchoolSearch do
  describe '#search' do
    before do
      allow(Geocoder).to receive(:search).and_return([])
    end

    let!(:matching_school) do
      create(
        :bookings_school,
        name: "Springfield Primary School",
        coordinates: Bookings::School::GEOFACTORY.point(-2.241, 53.481),
        fee: 10
      )
    end

    let!(:non_matching_school) do
      create(
        :bookings_school,
        name: "Pontefract Primary School",
        coordinates: Bookings::School::GEOFACTORY.point(-1.548, 53.794),
        fee: 30
      )
    end

    context 'When no conditions are supplied' do
      subject { Bookings::SchoolSearch.new.search('', location: '') }
      specify 'results should include all schools' do
        expect(subject.count).to eql(Bookings::School.count)
      end
    end

    context 'When Geocoder finds a location' do
      before do
        allow(Geocoder).to receive(:search).and_return(
          [
            OpenStruct.new(data: { "lat" => "53.488", "lon" => "-2.242" }),
            OpenStruct.new(data: { "lat" => "53.476", "lon" => "-2.229" })
          ]
        )
      end

      context 'When text and location are supplied' do
        subject { Bookings::SchoolSearch.new.search('Springfield', location: 'Manchester') }

        specify 'results should include matching records' do
          expect(subject).to include(matching_school)
        end

        specify 'results should not include non-matching records' do
          expect(subject).not_to include(non_matching_school)
        end
      end

      context 'When only text is supplied' do
        subject { Bookings::SchoolSearch.new.search('Springfield') }

        let!(:matching_school) do
          create(:bookings_school, name: "Springfield Primary School")
        end

        specify 'results should include matching records' do
          expect(subject).to include(matching_school)
        end

        specify 'results should not include non-matching records' do
          expect(subject).not_to include(non_matching_school)
        end
      end

      context 'When only a location is supplied' do
        subject { Bookings::SchoolSearch.new.search('', location: 'Manchester') }

        let!(:matching_school) do
          create(:bookings_school, name: "Springfield Primary School")
        end

        specify 'results should include matching records' do
          expect(subject).to include(matching_school)
        end

        specify 'results should not include non-matching records' do
          expect(subject).not_to include(non_matching_school)
        end
      end
    end

    context 'When GeoCoder finds no location' do
      context 'When the query matches a school' do
        subject { Bookings::SchoolSearch.new.search('Springfield', location: 'Madrid') }

        specify 'results should include records that match the query' do
          expect(subject).to include(matching_school)
        end
      end

      context 'When the query does not match a school' do
        subject { Bookings::SchoolSearch.new.search('William McKinley High', location: 'Chippewa, Michigan') }

        specify 'results should include records that match the query' do
          expect(subject).to be_empty
        end
      end
    end

    context 'Filtering' do
      # subjects
      let(:maths) { create(:bookings_subject, name: "Maths") }
      let(:physics) { create(:bookings_subject, name: "Physics") }
      # phases
      let(:college) { create(:bookings_phase, name: "College") }
      let(:secondary) { create(:bookings_phase, name: "Secondary") }

      context 'Filtering on subjects' do
        before do
          matching_school.subjects << maths
          non_matching_school.subjects << physics
        end

        subject { Bookings::SchoolSearch.new.search('', location: '', subject_ids: maths) }

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

        subject { Bookings::SchoolSearch.new.search('', location: '', phase_ids: college) }

        specify 'should return matching results' do
          expect(subject).to include(matching_school)
        end

        specify 'should omit non-matching results' do
          expect(subject).not_to include(non_matching_school)
        end
      end

      context 'Filtering on fees' do
        subject { Bookings::SchoolSearch.new.search('', location: '', max_fee: 20) }

        specify 'should return matching results' do
          expect(subject).to include(matching_school)
        end

        specify 'should omit non-matching results' do
          expect(subject).not_to include(non_matching_school)
        end
      end
    end
  end
end
