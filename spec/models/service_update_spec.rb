require 'rails_helper'

describe ServiceUpdate, type: :model do
  let :attrs do
    {
      date: '2020-06-01',
      title: 'Service Update A',
      summary: 'This is a short summary of Update A',
      html_content: "This is the full description of Update A.\n\nWith a longer explanation",
    }
  end

  let(:service_update) { described_class.new attrs }

  describe 'class' do
    subject { described_class.cookie_key }
    it { is_expected.to eql 'latest-viewed-service-update' }
  end

  describe 'attributes' do
    subject { described_class.new attrs }

    it { is_expected.to have_attributes date: Date.parse(attrs[:date]) }
    it { is_expected.to have_attributes title: attrs[:title] }
    it { is_expected.to have_attributes summary: attrs[:summary] }
    it { is_expected.to have_attributes html_content: attrs[:html_content] }
    it { is_expected.to have_attributes to_param: '2020-06-01' }
  end

  context 'with stub data' do
    let(:stub_dates) { %w[20010201 20200202 20200203] }
    before { allow(described_class).to receive(:ids) { stub_dates } }

    describe '.dates' do
      subject { described_class.dates }
      it { is_expected.to eql stub_dates }
    end

    describe '.latest_date' do
      subject { described_class.latest_date }
      it { is_expected.to eql '20200203' }
    end

    describe '.latest' do
      context 'without limit' do
        before do
          allow(described_class).to receive(:find).with(stub_dates.last) \
            { |date| described_class.new attrs.merge date: date }

          allow(described_class).to receive(:latest_date) { stub_dates.last }
        end

        subject! { described_class.latest }
        it { is_expected.to have_attributes date: Date.parse(stub_dates.last) }
        it { expect(described_class).to have_received(:latest_date) }
        it { expect(described_class).to have_received(:find).with(stub_dates.last) }
      end

      context 'with limit' do
        let(:updates) { build_list(:service_update, 10).index_by(&:id) }
        before { allow(described_class).to receive(:find) { |k| updates[k] } }
        before { allow(described_class).to receive(:dates) { updates.keys } }

        subject { described_class.latest(5) }

        it { is_expected.to eq updates.values.reverse.slice(0, 5) }
      end
    end
  end

  describe '.from_param' do
    before do
      allow(described_class).to \
        receive(:find).with('20200601') { service_update }
    end

    subject { described_class.from_param attrs[:date] }
    it { is_expected.to eq service_update }
  end

  describe "#title_with_date" do
    subject { described_class.new(attrs).title_with_date }

    it "returns the title preceded by the date" do
      expect(subject).to eq "1 June 2020 - Service Update A"
    end
  end
end
