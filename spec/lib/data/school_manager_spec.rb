require 'rails_helper'
require 'csv'
require File.join(Rails.root, "lib", "data", "school_manager")

describe SchoolManager do
  let(:urns) do
    [100111, 100112, 100113]
  end

  let(:raw_csv) do
    <<~SAMPLE
      urn
      #{urns.join("\n")}
    SAMPLE
  end

  let(:parsed_csv) do
    CSV.parse(raw_csv, headers: true)
  end

  subject { described_class.new(parsed_csv) }

  before do
    allow(STDOUT).to receive(:puts).and_return(true)
  end

  context 'Initialization' do
    specify 'should correctly set urns' do
      expect(subject.urns).to be_a(CSV::Table)
    end
  end

  context 'Enabling' do
    context 'when all schools exist' do
      let!(:targetted_schools) do
        urns.map { |urn| create(:bookings_school, urn: urn, enabled: false) }
      end
      let(:other_school) { create(:bookings_school, enabled: false) }

      before { subject.enable_urns }

      specify 'should enable supplied schools' do
        expect(targetted_schools.map(&:reload)).to all(be_enabled)
      end

      specify 'should not enable untargetted school' do
        expect(other_school).not_to be_enabled
      end

      specify 'should print out enabling status' do
        targetted_schools.each do |ts|
          expect(STDOUT).to have_received(:puts).with(
            "Updating #{ts.name}, enabled: true"
          )
        end
      end
    end

    context 'when some schools are missing' do
      let!(:targetted_schools) do
        urns.drop(1).map { |urn| create(:bookings_school, urn: urn, enabled: false) }
      end

      specify 'should raise an error' do
        expect { subject.enable_urns }.to raise_error(StandardError, "no school found with urn #{urns.first}")
      end
    end
  end

  context 'Disabling' do
    context 'when all schools exist' do
      let!(:targetted_schools) do
        urns.map { |urn| create(:bookings_school, urn: urn, enabled: true) }
      end
      let(:other_school) { create(:bookings_school, enabled: true) }

      before { subject.disable_urns }

      specify 'should disable supplied schools' do
        expect(targetted_schools.map(&:reload)).to all(be_disabled)
      end

      specify 'should not disable untargetted school' do
        expect(other_school).to be_enabled
      end

      specify 'should print out disabling status' do
        targetted_schools.each do |ts|
          expect(STDOUT).to have_received(:puts).with(
            "Updating #{ts.name}, enabled: false"
          )
        end
      end
    end

    context 'when some schools are missing' do
      let!(:targetted_schools) do
        urns.drop(1).map { |urn| create(:bookings_school, urn: urn, enabled: true) }
      end

      specify 'should raise an error' do
        expect { subject.disable_urns }.to raise_error(StandardError, "no school found with urn #{urns.first}")
      end
    end
  end
end
