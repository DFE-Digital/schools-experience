require 'rails_helper'

describe Schools::Search do
  describe '#search' do
    before do
      allow(Geocoder).to receive(:search).and_return([])
    end

    let!(:matching_school) do
      create(:school, name: "Springfield Primary School", coordinates: School::GEOFACTORY.point(-2.241, 53.481))
    end

    context 'When no conditions are supplied' do
      subject { Schools::Search.new.search('', location: '') }
      specify 'results should include all schools' do
        expect(subject.count).to eql(School.count)
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

      let!(:non_matching_school) do
        create(:school, name: "Pontefract Primary School", coordinates: School::GEOFACTORY.point(-1.548, 53.794))
      end

      context 'When text and location are supplied' do
        subject { Schools::Search.new.search('Springfield', location: 'Manchester') }

        specify 'results should include matching records' do
          expect(subject).to include(matching_school)
        end

        specify 'results should not include non-matching records' do
          expect(subject).not_to include(non_matching_school)
        end
      end

      context 'When only text is supplied' do
        subject { Schools::Search.new.search('Springfield') }

        let!(:matching_school) do
          create(:school, name: "Springfield Primary School")
        end

        specify 'results should include matching records' do
          expect(subject).to include(matching_school)
        end

        specify 'results should not include non-matching records' do
          expect(subject).not_to include(non_matching_school)
        end
      end

      context 'When only a location is supplied' do
        subject { Schools::Search.new.search('', location: 'Manchester') }

        let!(:matching_school) do
          create(:school, name: "Springfield Primary School")
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
        subject { Schools::Search.new.search('Springfield', location: 'Madrid') }

        specify 'results should include records that match the query' do
          expect(subject).to include(matching_school)
        end
      end

      context 'When the query does not match a school' do
        subject { Schools::Search.new.search('William McKinley High', location: 'Chippewa, Michigan') }

        specify 'results should include records that match the query' do
          expect(subject).to be_empty
        end
      end
    end
  end
end
