require 'rails_helper'
require 'csv'
require File.join(Rails.root, "lib", "data", "school_importer")

describe SchoolImporter do
  context 'Initialization' do
    let(:tpuk_data) do
      CSV.parse(
        File.read(File.join(Rails.root, 'spec', 'sample_data', 'tpuk.csv')).scrub,
        headers: true
      )
    end

    let(:edubase_data) do
      CSV.parse(
        File.read(File.join(Rails.root, 'spec', 'sample_data', 'edubase.csv')).scrub,
        headers: true
      )
    end

    context 'URNS' do
      subject { SchoolImporter.new(tpuk_data, []) }

      specify 'should remove markers from URN list' do
        expect(subject.tpuk_data.keys).to eql([100492, 100494, 100171])
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

      before do
        # note these values are present in spec/sample_data/edubase.csv
        {
         1 => 'Early years',
         2 => 'Primary (4 to 11)',
         4 => 'Secondary (11 to 16)',
         6 => '16 to 18',
         7 => 'All through'
        }.each do |i, name|
          create(:bookings_phase, name: name, edubase_id: i)
        end
        create(:bookings_school_type, edubase_id: school_type_id)
      end

      subject { SchoolImporter.new(tpuk_data, edubase_data) }

      before { subject.import }

      specify 'it should import the correct number of rows' do
        expect(Bookings::School.count).to eql(count_before + subject.tpuk_data.keys.size)
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
            postcode: "W10 5EF",
            contact_email: "email.100492@school.org"
          },
          100494 => {
            name: "Saint Francis of Assisi Catholic Primary School",
            website: "http://www.stfrancisofassisi.org.uk",
            address_1: "Treadgold Street",
            address_2: "Notting Hill",
            address_3: nil,
            town: "London",
            county: nil,
            postcode: "W11 4BJ",
            contact_email: "email.100494@school.org"
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

      context 'Cleaning up websites' do
        specify 'invalid websites should raise errors' do
          expect { subject.send(:cleanup_website, 101010, "invalidcom") }.to raise_error(
            RuntimeError, "invalid hostname for 101010, invalidcom"
          )
        end

        specify 'invalid protocols should raise errors' do
          expect { subject.send(:cleanup_website, 101010, "httpppp://invalid.com") }.to raise_error(
            RuntimeError, "invalid website for 101010, httpppp://invalid.com"
          )
        end
      end

      specify 'the new records should have the corret phases' do
        {
          100492 => ['Primary (4 to 11)'],
          100171 => ['Early years', 'Primary (4 to 11)', 'Secondary (11 to 16)', '16 to 18']
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

      context 'Overriding email addresses' do
        let(:email_override) { "someone@someschool.org" }
        subject { SchoolImporter.new(tpuk_data, edubase_data, email_override) }

        specify "all emails should be set to the override email address" do
          Bookings::School.all.each do |school|
            expect(school.contact_email).to eql(email_override)
          end
        end
      end
    end
  end
end
