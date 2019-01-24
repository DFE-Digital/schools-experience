require 'rails_helper'

describe 'Concerns' do
  describe 'GeographicSearch' do
    describe '.close_to' do
      subject { Bookings::School }

      let(:geofactory) { subject::GEOFACTORY }

      let!(:mcr_victoria) do
        create(:school, coordinates: geofactory.point(-2.242, 53.488))
      end

      let!(:mcr_piccadilly) do
        create(:school, coordinates: geofactory.point(-2.229, 53.476))
      end

      let!(:leeds_station) do
        create(:school, coordinates: geofactory.point(-1.548, 53.794))
      end

      let(:mcr_centre) { geofactory.point(-2.241, 53.481) }
      let(:leeds_centre) { geofactory.point(-1.543, 53.797) }

      specify 'should return records that fall inside the radius of a point' do
        expect(subject.close_to(mcr_centre)).to include(mcr_victoria, mcr_piccadilly)
        expect(subject.close_to(leeds_centre)).to include(leeds_station)
      end

      specify 'should not return records that fall outside the radius of a point' do
        expect(subject.close_to(mcr_centre)).not_to include(leeds_station)
        expect(subject.close_to(leeds_centre)).not_to include(mcr_victoria, mcr_piccadilly)
      end

      context 'custom radius' do
        specify 'should return records that fall inside a custom radius of a point' do
          expect(subject.close_to(mcr_centre, radius: 50)).to include(leeds_station)
          expect(subject.close_to(leeds_centre, radius: 50)).to include(mcr_piccadilly, mcr_victoria)
        end

        specify 'should not return records that fall outside the custom radius of a point' do
          expect(subject.close_to(mcr_centre, radius: 15)).not_to include(leeds_station)
        end

        specify 'should allow non-integer numbers' do
          expect(subject.close_to(leeds_centre, radius: 1.2)).to include(leeds_station)
          expect(subject.close_to(mcr_centre, radius: 1.2)).not_to include(leeds_station)
        end
      end
    end
  end
end
