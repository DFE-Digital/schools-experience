require 'rails_helper'
require 'csv'

describe Bookings::Data::SchoolMassImporter do
  before do
    allow(STDOUT).to receive(:puts).and_return(true)
    allow_any_instance_of(Kernel).to receive(:print).and_return(nil)
  end

  context 'Initialization' do
    let(:edubase_data) do
      CSV.parse(
        Rails.root.join('spec', 'sample_data', 'edubase.csv').read.scrub,
        headers: true
      )
    end

    context 'EduBase Data' do
      subject { Bookings::Data::SchoolMassImporter.new([], edubase_data).edubase_data }

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

      subject { Bookings::Data::SchoolMassImporter.new(edubase_data) }

      before { subject.import }

      specify 'it should import the correct number of rows' do
        expect(Bookings::School.count).to eql(count_before + edubase_data.size)
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
            contact_email: nil
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
            contact_email: nil
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
        subject { Bookings::Data::SchoolMassImporter.new(edubase_data, email_override) }

        specify "all emails should be set to the override email address" do
          Bookings::School.all.each do |school|
            expect(school.contact_email).to eql(email_override)
          end
        end
      end
    end
  end
end
