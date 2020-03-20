require 'rails_helper'
require 'csv'

describe Bookings::Data::SchoolUpdater do
  let(:edubase_data) do
    CSV.parse(
      Rails.root.join('spec', 'sample_data', 'edubase.csv').read.scrub,
      headers: true
    )
  end

  context 'Initialization' do
    context 'EduBase Data' do
      subject { described_class.new(edubase_data).edubase_data }

      specify 'should be iterable' do
        expect(subject).to be_a Enumerable
      end

      specify 'contents should be raw CSV rows' do
        expect(subject).to all be_a(CSV::Row)
      end
    end
  end

  context 'Updating' do
    let(:school_100492) do
      OpenStruct.new(
        actual_name: "St Thomas' CofE Primary School",
        address_1: "Appleford Road",
        address_2: "North Kensington",
        town: "London",
        postcode: "W10 5EF",
        record: create(:bookings_school, urn: 100492)
      )
    end
    let(:school_100459) do
      OpenStruct.new(
        actual_name: "St Aloysius RC College",
        address_1: "Hornsey Lane",
        addresS_2: "Highgate",
        town: "London",
        postcode: "N6 5LY",
        record: create(:bookings_school, urn: 100459)
      )
    end

    let(:school_100494) do
      OpenStruct.new(
        actual_name: "Saint Francis of Assisi Catholic Primary School",
        address_1: "Treadgold Street",
        addresS_2: "Notting Hill",
        town: "London",
        postcode: "W11 4BJ",
        record: create(:bookings_school, urn: 100494)
      )
    end
    let!(:schools) { [school_100492, school_100459, school_100494] }

    # missing school not actuall tested, just ensure update doesn't crash
    # because it's missing
    let!(:missing_school_urn) { 100171 }

    context 'performing updates correctly' do
      before { described_class.new(edubase_data).update }

      specify 'values should match those in the source data' do
        schools.each do |school|
          expect(school.record.reload.name).to eql(school.actual_name)
          expect(school.record.reload.address_1).to eql(school.address_1)
        end
      end
    end
  end
end
