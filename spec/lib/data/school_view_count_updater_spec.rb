require 'rails_helper'
require 'csv'
require File.join(Rails.root, "lib", "data", "school_view_count_updater")

describe SchoolViewCountUpdater do
  let(:raw_count_seed_data_file) do
    Rails.root.join('spec', 'sample_data', 'school_view_counts_sample.csv')
  end

  let(:raw_count_seed_data) do
    CSV.read(raw_count_seed_data_file, headers: true)
  end

  let!(:schools) do
    raw_count_seed_data.map do |row|
      FactoryBot.create(:bookings_school, urn: row['urn'])
    end
  end

  subject { SchoolViewCountUpdater.new(raw_count_seed_data_file) }

  specify 'should initialize with correct data' do
    expect(subject).to be_a(described_class)
    expect(subject.seeds.length).to eql(3)
  end

  context '#update' do
    subject { SchoolViewCountUpdater.new(raw_count_seed_data_file) }

    let(:counts) do
      # these counts match the data in raw_count_seed_data_file
      { 140000 => 10, 140001 => 100, 140002 => 1000 }
    end

    # suppress console output
    before { allow(STDOUT).to receive(:puts).and_return(true) }
    before { subject.update }

    specify 'should update the schools with the correct counts' do
      counts.each do |urn, total|
        expect(Bookings::School.find_by(urn: urn).views).to eql(total)
      end
    end
  end
end
