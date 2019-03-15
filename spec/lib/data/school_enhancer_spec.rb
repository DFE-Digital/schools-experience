require 'rails_helper'
require 'csv'
require File.join(Rails.root, "lib", "data", "school_enhancer")

describe SchoolEnhancer do
  let(:raw_response_data) do
    CSV.parse(
      File.read(Rails.root.join('spec', 'sample_data', 'onboarding_responses.csv')).scrub,
      headers: true
    )
  end

  let(:invalid_response_data) do
    CSV.parse(
      File.read(Rails.root.join('spec', 'sample_data', 'tpuk.csv')).scrub,
      headers: true
    )
  end

  context 'Initialization' do
    specify 'should correctly read rows with necessary headers' do
      expect(described_class.new(raw_response_data)).to be_a(SchoolEnhancer)
    end

    specify "should fail with 'Missing fields' if incorrect CSV supplied" do
      expect { described_class.new(invalid_response_data) }.to raise_error(RuntimeError, /Missing fields/)
    end
  end

  context '#enhance' do
    let(:subject_names) { %w{Biology Chemistry English Maths} }
    let!(:imported_school) { FactoryBot.create(:bookings_school, urn: 100492) }
    subject { described_class.new(raw_response_data) }

    before do
      subject_names.each do |subject|
        FactoryBot.create(:bookings_subject, name: subject)
      end
    end

    before do
      allow(STDOUT).to receive(:puts).and_return(true)
      allow(Rails.logger).to receive(:warn).and_return(true)
    end

    before do
      subject.enhance
    end

    specify 'should log warning if school cannot be found' do
      [100494, 100171].each do |urn|
        expect(Rails.logger).to have_received(:warn).with("No existing school found with URN: #{urn}")
      end
    end

    specify 'should correctly set provided attributes' do
      Bookings::School.find_by(urn: 100492).tap do |school|
        expect(school.placement_info).to match(/We can arrange this informally by prior email/)
        expect(school.availability_info).to match(/Spring Term 2019/)
        expect(school.primary_key_stage_info).to match(/Primary Key Stages 1 and 2/)
        expect(school.teacher_training_info).to match(/We are a lead school/)
        expect(school.teacher_training_website).to eql("http://summer-heights.co.uk/")
      end
    end

    specify 'should correctly assign provided subjects' do
      expect(Bookings::School.find_by(urn: 100492).subjects.map(&:name).sort).to eql(subject_names)
    end
  end
end
