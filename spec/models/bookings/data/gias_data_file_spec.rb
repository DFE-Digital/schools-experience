require 'rails_helper'
require 'tmpdir'

describe Bookings::Data::GiasDataFile do
  let(:gias_data_file) { described_class.new }
  let(:today) { gias_data_file.today }
  let(:valid_file_contents) { "#{described_class::EXPECTED_HEADER}\n10000,\n" }
  let(:temp_root) { Dir.mktmpdir }

  before do
    stub_const('Bookings::Data::GiasDataFile::TEMP_PATH', Pathname.new(temp_root).join('gias'))
  end

  after { FileUtils.remove_entry(temp_root) }

  describe '#path' do
    context 'with existing file' do
      before do
        FileUtils.mkdir_p(described_class::TEMP_PATH)
        File.write(gias_data_file.todays_file, valid_file_contents)
        allow(Net::HTTP).to receive(:get).and_call_original
      end

      it "returns path of todays file" do
        expect(gias_data_file.path).to eql(
          described_class::TEMP_PATH.join("edubase-#{today}.csv")
        )
      end

      it "does not download an existing file" do
        gias_data_file.path

        expect(Net::HTTP).not_to have_received(:get)
      end
    end

    context 'without existing file' do
      before do
        stub_request(:get, gias_data_file.source_url).to_return(
          status: 200,
          body: valid_file_contents
        )
      end

      it "returns path of todays file" do
        expect(gias_data_file.path).to eql(
          described_class::TEMP_PATH.join("edubase-#{today}.csv")
        )
      end

      it "downloads a new file" do
        path = gias_data_file.path

        expect(File.read(path)).to eq(valid_file_contents)
      end

      it "creates temp dir" do
        gias_data_file.path

        expect(File.directory?(described_class::TEMP_PATH)).to be(true)
      end
    end

    context 'with an invalid source file' do
      before do
        stub_request(:get, gias_data_file.source_url).to_return(
          status: 200,
          body: 'invalid source'
        )
      end

      it "raises an exception and removes the file" do
        expect { gias_data_file.path }.to raise_exception(described_class::InvalidSourceUri)
        expect(File.exist?(gias_data_file.todays_file)).to be(false)
      end
    end
  end

  describe '#remove_old_files!' do
    let(:yesterday) { Time.zone.yesterday.strftime('%Y%m%d') }
    let(:tomorrow) { Time.zone.tomorrow.strftime('%Y%m%d') }

    before do
      FileUtils.mkdir_p(described_class::TEMP_PATH)
      [yesterday, today, tomorrow].each do |day|
        File.write(described_class::TEMP_PATH.join("edubase-#{day}.csv"), '')
      end

      gias_data_file.remove_old_files!
    end

    it "removes yesterday's file" do
      expect(File.exist?(described_class::TEMP_PATH.join("edubase-#{yesterday}.csv"))).to be(false)
    end

    it "removes tomorrow's file" do
      expect(File.exist?(described_class::TEMP_PATH.join("edubase-#{tomorrow}.csv"))).to be(false)
    end

    it "keeps today's file" do
      expect(File.exist?(described_class::TEMP_PATH.join("edubase-#{today}.csv"))).to be(true)
    end
  end

  describe '#remove_todays_file!' do
    let(:yesterday) { Time.zone.yesterday.strftime('%Y%m%d') }

    before do
      FileUtils.mkdir_p(described_class::TEMP_PATH)
      [yesterday, today].each do |day|
        File.write(described_class::TEMP_PATH.join("edubase-#{day}.csv"), '')
      end

      gias_data_file.remove_todays_file!
    end

    it "keeps yesterday's file" do
      expect(File.exist?(described_class::TEMP_PATH.join("edubase-#{yesterday}.csv"))).to be(true)
    end

    it "removes today's file" do
      expect(File.exist?(described_class::TEMP_PATH.join("edubase-#{today}.csv"))).to be(false)
    end
  end

  context 'when valid_file?' do
    let(:file_contents) { '' }

    before do
      FileUtils.mkdir_p(described_class::TEMP_PATH)
      File.write(gias_data_file.todays_file, file_contents)
    end

    context 'with empty file' do
      it { expect(gias_data_file).not_to be_valid_file }
    end

    context 'with header only' do
      let(:file_contents) { "#{described_class::EXPECTED_HEADER}\n" }

      it { expect(gias_data_file).not_to be_valid_file }
    end

    context 'with header and body' do
      let(:file_contents) { valid_file_contents }

      it { expect(gias_data_file).to be_valid_file }
    end
  end
end
