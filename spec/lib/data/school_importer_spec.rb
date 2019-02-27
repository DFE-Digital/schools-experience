require 'rails_helper'
require 'csv'
require File.join(Rails.root, "lib", "data", "school_importer")

describe SchoolImporter do
  context 'Initialization' do
    # note URNs will be read from a CSV so are all strings at this point
    let(:urns) { %w{URN 100492 SCITT 100494 TRUST TSA} }
    let(:edubase_data) do
      CSV.parse(
        File.read(File.join(Rails.root, 'spec', 'sample_data', 'edubase.csv')).scrub,
        headers: true
      )
    end


    context 'URNS' do
      subject { SchoolImporter.new(urns, []) }

      specify 'should remove markers from URN list' do
        expect(subject.urns).to eql([100492, 100494])
      end
    end

    context 'EduBase Data' do
      subject { SchoolImporter.new([], edubase_data).edubase_data }

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

    context 'Importing' do
      let!(:count_before) { Bookings::School.count }
      let(:school_type_id) { 2 }
      let(:urns) { %w{100492 100494 100171} }

      before do
        # note these values are present in spec/sample_data/edubase.csv
        {
         1 => 'Nursery',
         2 => 'Primary',
         4 => 'Secondary',
         6 => '16 plus',
         7 => 'All through'
        }.each do |i, name|
          create(:bookings_phase, name: name, edubase_id: i)
        end
        create(:bookings_school_type, edubase_id: school_type_id)
      end

      subject { SchoolImporter.new(urns, edubase_data) }

      before { subject.import }

      specify 'it should import the correct number of rows' do
        expect(Bookings::School.count).to eql(count_before + subject.urns.size)
      end

      specify 'the new records should have the correct attributes' do
        {
          100492 => {
            name: "St Thomas' CofE Primary School",
            website: "http://www.st.rbkc.sch.uk",
            address_1: "Appleford Road",
            address_2: "North Kensington",
            address_3: nil,
            town: "London",
            county: nil,
            postcode: "W10 5EF"
          },
          100494 => {
            name: "Saint Francis of Assisi Catholic Primary School",
            website: "http://www.stfrancisofassisi.org.uk",
            address_1: "Treadgold Street",
            address_2: "Notting Hill",
            address_3: nil,
            town: "London",
            county: nil,
            postcode: "W11 4BJ"
          }
        }.each do |urn, attributes|
          Bookings::School.find_by(urn: urn).tap do |school|
            expect(school).to have_attributes(attributes)
            expect(school.school_type).to eql(
              Bookings::SchoolType.find_by(edubase_id: school_type_id)
            )
          end
        end
      end

      specify 'the new records should have the corret phases' do
        {
          100492 => %w{Primary},
          100171 => ['Nursery', 'Primary', 'Secondary', '16 plus']
        }.each do |urn, phase_names|
          Bookings::School.find_by(urn: urn).tap do |school|
            expect(school.phases.map(&:name)).to match_array(phase_names)
          end
        end
      end

      specify 'the new records should have coordinates' do
        # we're relying on Breasal to do the maths, so just check
        # they're populated
        Bookings::School.all.each do |school|
          expect(school.coordinates).to be_present
        end
      end
    end
  end
end
