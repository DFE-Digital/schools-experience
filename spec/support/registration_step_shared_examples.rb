# These shared examples isolate timestamp persistence from each form's validation rules.
shared_examples 'a registration step' do
  subject(:registration_step) do
    described_class.new(urn: school.urn)
  end

  let! :datetime do
    DateTime.now
  end

  let! :new_datetime do
    datetime + 1.day
  end

  context 'when calling methods' do
    it { is_expected.to respond_to :persisted? }
    it { is_expected.to respond_to :flag_as_persisted! }
    it { is_expected.to respond_to :created_at }
    it { is_expected.to respond_to :updated_at }
  end

  context 'when unpersisted' do
    before do
      allow(DateTime).to receive(:now) { datetime }
    end

    describe '#created_at' do
      it 'is nil' do
        expect(subject.created_at).to be_nil
      end
    end

    describe '#updated_at' do
      it 'is nil' do
        expect(subject.updated_at).to be_nil
      end
    end

    describe '#persisted?' do
      it 'is false' do
        expect(subject).not_to be_persisted
      end
    end

    describe '#flag_as_persisted!' do
      context 'when invalid' do
        it 'raises a validation error' do
          expect { subject.flag_as_persisted! }.to raise_error \
            ActiveModel::ValidationError
        end
      end

      context 'when valid' do
        before do
          allow(registration_step).to receive(:valid?).and_return(true)
          subject.flag_as_persisted!
        end

        it 'sets the created_at' do
          expect(subject.created_at).to eq datetime
        end

        it 'sets the updated_at' do
          expect(subject.updated_at).to eq datetime
        end
      end
    end
  end

  context 'when persisted' do
    before do
      # setting a value for created_at flags a model as persisted.
      subject.created_at = datetime
      allow(DateTime).to receive(:now) { new_datetime }
    end

    describe '#persisted?' do
      it 'is true' do
        expect(subject).to be_persisted
      end
    end

    describe '#persisted!' do
      context 'when invalid' do
        # ie a bad update attempt
        it 'raises a validation error' do
          expect { subject.flag_as_persisted! }.to raise_error \
            ActiveModel::ValidationError
        end
      end

      context 'when valid' do
        before do
          allow(registration_step).to receive(:valid?).and_return(true)
          subject.flag_as_persisted!
        end

        it "doesn't change the created_at" do
          expect(subject.created_at).to eq datetime
        end

        it 'sets the updated_at to the current time' do
          expect(subject.updated_at).to eq new_datetime
        end
      end
    end
  end
end
