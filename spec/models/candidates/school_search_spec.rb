require 'rails_helper'

RSpec.describe Candidates::SchoolSearch do
  describe "validation" do
    describe "#location" do
      it { is_expected.not_to allow_values("", "a").for :location }
      it { is_expected.to allow_value("aaa").for :location }
    end
  end

  describe ".encrypted_attributes" do
    subject { described_class.encrypted_attributes }

    it { is_expected.to eq(%w[location]) }
  end

  describe '.new' do
    subject do
      described_class.new(
        query: 'this',
        location: 'manchester',
        distance: '3',
        max_fee: '30',
        phases: [1, 2, 3],
        subjects: [4, 5, 6],
        dbs_policies: [2],
        disability_confident: '1',
        parking: '1'
      )
    end

    it 'assigns attributes' do
      expect(subject.query).to eq('this')
      expect(subject.distance).to eq(3)
      expect(subject.location).to eq('manchester')
      expect(subject.max_fee).to eq('30')
      expect(subject.phases).to eq([1, 2, 3])
      expect(subject.subjects).to eq([4, 5, 6])
      expect(subject.dbs_policies).to eq([2])
      expect(subject.disability_confident).to eq('1')
      expect(subject.parking).to eq('1')
    end
  end

  describe '.new_decrypt' do
    let(:message) { I18n.t('candidates.school_searches.unreadable_location') }

    shared_examples 'unreadable location' do
      it 'is invalid with a location error that survives revalidation' do
        expect(subject.errors[:location]).to eq([message])
        2.times { expect(subject).not_to be_valid }
        expect(subject.errors[:location]).to eq([message])
      end

      it 'clears the location and coordinates without geocoding' do
        allow(Bookings::SchoolSearch).to receive(:new)
        expect(subject.location).to be_nil
        expect(subject.latitude).to be_nil
        expect(subject.longitude).to be_nil
        expect(subject.valid_search?).to be(false)
        expect(Bookings::SchoolSearch).not_to have_received(:new)
      end
    end

    context 'when the token raises Hashids::InputError' do
      subject { described_class.new_decrypt(location: 'bad!token', latitude: '53.4', longitude: '-2.2') }

      it { expect { Encryptor.decrypt('bad!token') }.to raise_error(Hashids::InputError) }

      include_examples 'unreadable location'
    end

    context 'when the token decodes to an empty value' do
      subject { described_class.new_decrypt(location: 'Rochdale', latitude: '53.4', longitude: '-2.2') }

      it { expect(Encryptor.decrypt('Rochdale')).to eq('') }

      include_examples 'unreadable location'
    end

    it 'decodes a valid location' do
      search = described_class.new_decrypt(location: Encryptor.encrypt('Manchester'))
      expect(search.location).to eq('Manchester')
      expect(search.errors[:location]).to be_empty
    end

    it 'keeps coordinate-only searches' do
      search = described_class.new_decrypt(latitude: '53.4', longitude: '-2.2')
      expect(search.latitude).to eq('53.4')
      expect(search.valid_search?).to be(true)
    end

    it 'propagates unrelated exceptions' do
      allow(Encryptor).to receive(:decrypt).and_raise(StandardError, 'boom')
      expect { described_class.new_decrypt(location: 'x') }.to raise_error(StandardError, 'boom')
    end
  end

  context 'when delegating' do
    it { expect(subject).to delegate_method(:valid?).to(:school_search) }
    it { expect(subject).to delegate_method(:errors).to(:school_search) }
    it { expect(subject).to delegate_method(:location_name).to(:school_search) }
    it { expect(subject).to delegate_method(:has_coordinates?).to(:school_search) }
    it { expect(subject).to delegate_method(:phase_count).to(:school_search) }
    it { expect(subject).to delegate_method(:subject_count).to(:school_search) }
    it { expect(subject).to delegate_method(:dbs_not_required_count).to(:school_search) }
    it { expect(subject).to delegate_method(:disability_confident_count).to(:school_search) }
    it { expect(subject).to delegate_method(:parking_count).to(:school_search) }
  end

  describe '.subjects=' do
    context 'with blank strings' do
      before { subject.subjects = [1, '', 3] }

      it 'removes blank strings' do
        expect(subject.subjects).to eq [1, 3]
      end
    end

    context 'with nils' do
      before { subject.subjects = [1, 3, nil] }

      it 'removes nils' do
        expect(subject.subjects).to eq [1, 3]
      end
    end

    context 'with single values' do
      before { subject.subjects = 1 }

      it 'convert single values to arrays' do
        expect(subject.subjects).to eq [1]
      end
    end

    context 'with string values' do
      before { subject.subjects = ['1', '2', 3] }

      it 'converts to integers' do
        expect(subject.subjects).to eq [1, 2, 3]
      end
    end
  end

  describe '.phases=' do
    context 'with blank strings' do
      before { subject.phases = [1, '', 3] }

      it 'removes blank strings' do
        expect(subject.phases).to eq [1, 3]
      end
    end

    context 'with nils' do
      before { subject.phases = [1, 3, nil] }

      it 'removes nils' do
        expect(subject.phases).to eq [1, 3]
      end
    end

    context 'with single values' do
      before { subject.phases = 1 }

      it 'convert single values to arrays' do
        expect(subject.phases).to eq [1]
      end
    end

    context 'with string values' do
      before { subject.phases = ['1', '2', 3] }

      it 'converts to integers' do
        expect(subject.phases).to eq [1, 2, 3]
      end
    end
  end

  describe '.dbs_policies=' do
    context 'with blank strings' do
      before { subject.dbs_policies = [1, '', 3] }

      it 'removes blank strings' do
        expect(subject.dbs_policies).to eq [1, 3]
      end
    end

    context 'with nils' do
      before { subject.dbs_policies = [1, 3, nil] }

      it 'removes nils' do
        expect(subject.dbs_policies).to eq [1, 3]
      end
    end

    context 'with single values' do
      before { subject.dbs_policies = 1 }

      it 'convert single values to arrays' do
        expect(subject.dbs_policies).to eq [1]
      end
    end

    context 'with string values' do
      before { subject.dbs_policies = ['1', '2', 3] }

      it 'converts to integers' do
        expect(subject.dbs_policies).to eq [1, 2, 3]
      end
    end
  end

  context 'when max_fee=' do
    context 'with known value' do
      before { subject.max_fee = '30' }

      it('is 30') do
        expect(subject.max_fee).to eq '30'
      end
    end

    context 'with known value as integer' do
      before { subject.max_fee = 30 }

      it('is 30') do
        expect(subject.max_fee).to eq '30'
      end
    end

    context 'with unknown value' do
      before { subject.max_fee = '20000' }

      it('is blank') do
        expect(subject.max_fee).to eq ''
      end
    end

    context 'with blank value' do
      before { subject.max_fee = '' }

      it('is blank') do
        expect(subject.max_fee).to eq ''
      end
    end

    context 'with nil value' do
      before { subject.max_fee = nil }

      it('is blank') do
        expect(subject.max_fee).to eq ''
      end
    end
  end

  describe '.results' do
    subject { described_class.new(query: 'Test School') }

    it 'returns array of Schools' do
      expect(subject.results).to be_a Enumerable
    end
  end

  describe '.total_count' do
    subject { described_class.new(query: 'Test School') }

    it 'returns array of Schools' do
      expect(subject.total_count).to be_a Integer
    end
  end

  describe '.valid_search?' do
    context 'with query' do
      subject { described_class.new(query: 'Test School') }

      it('is valid') { expect(subject.valid_search?).to be true }
    end

    context 'with only location' do
      subject { described_class.new(location: 'Manchester', distance: '') }

      it('is invalid') { expect(subject.valid_search?).to be false }
    end

    context 'with only distance' do
      subject { described_class.new(distance: '10') }

      it('is invalid') { expect(subject.valid_search?).to be false }
    end

    context 'with location and distance' do
      subject { described_class.new(location: 'Manchester', distance: '10') }

      it('is valid') { expect(subject.valid_search?).to be true }
    end

    context 'with latitude and distance' do
      subject { described_class.new(latitude: '-2.241', distance: '10') }

      it('is invalid') { expect(subject.valid_search?).to be false }
    end

    context 'with longitude and distance' do
      subject { described_class.new(longitude: '53.481', distance: '10') }

      it('is invalid') { expect(subject.valid_search?).to be false }
    end

    context 'with latitude, longitude and distance' do
      subject do
        described_class.new(
          distance: '10', longitude: '53.481', latitude: '-2.241'
        )
      end

      it('is valid') { expect(subject.valid_search?).to be true }
    end

    context 'with query, location and distance' do
      subject do
        described_class.new(
          query: 'test',
          location: 'Manchester',
          distance: '10'
        )
      end

      it('is valid') { expect(subject.valid_search?).to be true }
    end
  end

  describe '.filtering_results' do
    context 'when the search is blank' do
      subject { described_class.new }

      it "is false" do
        expect(subject).not_to be_filtering_results
      end
    end

    context 'when the search is valid' do
      subject { described_class.new(query: "test") }

      it "is true" do
        expect(subject).to be_filtering_results
      end
    end
  end

  describe "#applied_filters" do
    subject { instance.applied_filters }

    let!(:first_subject) { create(:bookings_subject, name: "Subject 1") }
    let!(:second_subject) { create(:bookings_subject, name: "Subject 2") }
    let!(:primary_phase) { create(:bookings_phase, :primary) }
    let!(:secondary_phase) { create(:bookings_phase, :secondary) }

    let(:instance) do
      described_class.new(
        subjects: [first_subject.id, second_subject.id],
        phases: [primary_phase.id, secondary_phase.id],
        dbs_policies: [2],
        disability_confident: "1",
        parking: "1"
      )
    end


    it do
      expect(subject).to eq({
        "Subjects" => {
          subjects: [{ value: first_subject.id, text: "Subject 1" }, { value: second_subject.id, text: "Subject 2" }]
        },
        "Education phases" => {
          phases: [{ value: primary_phase.id, text: "Primary (4 to 11)" }, { value: secondary_phase.id, text: "Secondary (11 to 16)" }]
        },
        "Requirements" => {
          dbs_policies: [{ value: 2, text: "DBS check: Not required" }],
          disability_confident: [{ value: "1", text: "Disability Confident schools" }],
          parking: [{ value: "1", text: "Schools with parking" }]
        }
      })
    end
  end
end
