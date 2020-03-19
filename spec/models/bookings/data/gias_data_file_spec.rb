require 'rails_helper'

describe Bookings::Data::GiasDataFile do
  let(:today) { Time.zone.today.strftime('%Y%m%d') }

  describe '#path' do
    before { allow(subject).to receive(:valid_file?).and_return true }
    before { allow(subject).to receive(:already_downloaded?).and_return false }
    before { allow(subject).to receive(:remove_old_files!).and_return true }
    before { allow(subject).to receive(:remove_todays_file!).and_return true }
    before { allow(subject).to receive(:download_and_save) { subject.todays_file } }
    before { allow(subject).to receive(:create_temp_dir).and_return true }

    context 'with existing file' do
      before { allow(subject).to receive(:already_downloaded?).and_return true }
      let!(:path) { subject.path }

      it "will return path of todays file" do
        expect(path).to eql \
          Rails.root.join('tmp', 'gias', "edubase-#{today}.csv")
      end

      it "will return existing file" do
        is_expected.not_to have_received(:download_and_save)
      end

      it "will clean up old csv files" do
        is_expected.to have_received(:remove_old_files!)
      end

      it "will create temp dir" do
        is_expected.not_to have_received(:create_temp_dir)
      end
    end

    context 'without existing file' do
      let!(:path) { subject.path }

      it "will return path of todays file" do
        expect(path).to eql \
          Rails.root.join('tmp', 'gias', "edubase-#{today}.csv")
      end

      it "will download a new file" do
        is_expected.to have_received(:download_and_save)
      end

      it "will clean up old csv files" do
        is_expected.to have_received(:remove_old_files!)
      end

      it "will create temp dir" do
        is_expected.to have_received(:create_temp_dir)
      end
    end

    context 'with invalid source file' do
      before { allow(subject).to receive(:valid_file?).and_return false }

      it "will raise an exception and remove file" do
        expect { subject.path }.to raise_exception described_class::InvalidSourceUri
        is_expected.to have_received(:remove_todays_file!)
      end
    end
  end

  context '#remove_old_files' do
    let(:yesterday) { Time.zone.yesterday.strftime('%Y%m%d') }
    let(:today) { Time.zone.today.strftime('%Y%m%d') }
    let(:tomorrow) { Time.zone.tomorrow.strftime('%Y%m%d') }
    let(:files) do
      [yesterday, today, tomorrow].map do |day|
        described_class::TEMP_PATH.join("edubase-#{day}.csv").to_s
      end
    end

    before do
      allow(subject).to receive(:list_files).and_return(files)
      allow(File).to receive(:unlink).and_return(true)
      subject.remove_old_files!
    end

    it "will remove yesterdays" do
      expect(File).to have_received(:unlink).with \
        described_class::TEMP_PATH.join("edubase-#{yesterday}.csv").to_s
    end

    it "will remove tomorrows" do
      expect(File).to have_received(:unlink).with \
        described_class::TEMP_PATH.join("edubase-#{tomorrow}.csv").to_s
    end

    it "wont remove todays" do
      expect(File).not_to have_received(:unlink).with \
        described_class::TEMP_PATH.join("edubase-#{today}.csv").to_s
    end
  end

  context '#remove_todays_file!' do
    let(:yesterday) { Time.zone.yesterday.strftime('%Y%m%d') }
    let(:today) { Time.zone.today.strftime('%Y%m%d') }

    before do
      allow(File).to receive(:unlink).and_return(true)
      subject.remove_todays_file!
    end

    it "wont remove yesterdays" do
      expect(File).not_to have_received(:unlink).with \
        described_class::TEMP_PATH.join("edubase-#{yesterday}.csv")
    end

    it "will remove todays" do
      expect(File).to have_received(:unlink).with \
        described_class::TEMP_PATH.join("edubase-#{today}.csv")
    end
  end

  context 'valid_file?' do
    let(:tempfile) { Tempfile.new }
    before { allow(subject).to receive(:todays_file).and_return tempfile.path }

    context 'with empty file' do
      it { is_expected.to have_attributes valid_file?: false }
    end

    context 'with header only' do
      before { tempfile.write "#{described_class::EXPECTED_HEADER}\n" }
      before { tempfile.flush }
      it { is_expected.to have_attributes valid_file?: false }
    end

    context 'with header and body' do
      before { tempfile.write "#{described_class::EXPECTED_HEADER}\n10000,\n" }
      before { tempfile.flush }
      it { is_expected.to have_attributes valid_file?: true }
    end
  end
end
