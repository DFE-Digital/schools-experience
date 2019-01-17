require 'rails_helper'

describe 'Concerns' do
  describe 'GeographicSearch' do
    describe '.close_to' do

      subject { School }

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

      specify 'should return records that fall inside the radius' do
        expect(subject.close_to(mcr_centre)).to include(mcr_victoria, mcr_piccadilly)
      end

      specify 'should not return records that fall outside the radius' do
        expect(subject.close_to(mcr_centre)).not_to include(leeds_station)
      end

      context 'custom radius' do
        specify 'should allow a custom radius parameter' do
          expect(subject.close_to(mcr_centre, radius: 50)).to include(leeds_station)
        end
      end

    end
  end
end
