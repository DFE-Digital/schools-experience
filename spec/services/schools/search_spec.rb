require 'rails_helper'

describe Schools::Search do

  describe '#search' do

    let!(:non_matching_school) do
      create(
        :school, {
          name: "Pontefract Primary School",
          coordinates: School::GEOFACTORY.point(-1.548, 53.794)
        }
      )
    end


    before do
      allow(Geocoder).to receive(:search).and_return(
				[
          OpenStruct.new({data: {
            "lat" => "53.488",
				    "lon" =>"-2.242"
          }}),
          OpenStruct.new({data: {
            "lat" => "53.476",
				    "lon" =>"-2.229"
          }})
        ]
      )
    end

    context 'When text and location are supplied' do
      subject { Schools::Search.new.search('Springfield', location: 'Manchester') }

      let!(:matching_school) do
        create(
          :school, {
            name: "Springfield Primary School",
            coordinates: School::GEOFACTORY.point(-2.241, 53.481)
          }
        )
      end

      specify 'should return matching records' do
        expect(subject).to include(matching_school)
      end

      specify 'should not return non-matching records' do
        expect(subject).not_to include(non_matching_school)
      end
    end

    context 'When only text is supplied' do
      subject { Schools::Search.new.search('Springfield') }

      let!(:matching_school) do
        create(:school, { name: "Springfield Primary School" })
      end

      specify 'should return matching records' do
        expect(subject).to include(matching_school)
      end

      specify 'should not return non-matching records' do
        expect(subject).not_to include(non_matching_school)
      end
    end

    context 'When only a location is supplied' do
      subject { Schools::Search.new.search('', location: 'Manchester') }

      let!(:matching_school) do
        create(
          :school, {
            name: "Springfield Primary School",
          }
        )
      end

      specify 'should return matching records' do
        expect(subject).to include(matching_school)
      end

      specify 'should not return non-matching records' do
        expect(subject).not_to include(non_matching_school)
      end
    end

  end

end
