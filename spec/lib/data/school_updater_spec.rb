require 'rails_helper'
require 'csv'
require File.join(Rails.root, "lib", "data", "school_updater")

describe SchoolUpdater do
  before do
    allow(STDOUT).to receive(:puts).and_return(true)
  end

  let(:edubase_data) do
    CSV.parse(
      File.read(File.join(Rails.root, 'spec', 'sample_data', 'edubase.csv')).scrub,
      headers: true
    )
  end

  context 'Initialization' do
    context 'EduBase Data' do
      subject { described_class.new(edubase_data).edubase_data }

      specify 'should convert to a hash' do
        expect(subject).to be_a(Hash)
      end

      specify 'should be keyed by URN' do
        expect(subject.keys).to all(be_an(Integer))
      end

      specify 'values should be raw CSV rows' do
        expect(subject.values).to all(be_a(CSV::Row))
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
      specify 'values should match those in the source data' do
        described_class.new(edubase_data).update
        schools.each do |school|
          expect(school.record.reload.name).to eql(school.actual_name)
          expect(school.record.reload.address_1).to eql(school.address_1)
        end
      end
    end
  end
end
