shared_examples 'a registration step' do
  let! :datetime do
    DateTime.now
  end

  let! :new_datetime do
    datetime + 1.day
  end

  subject do
    if defined?(school)
      described_class.new(school: school)
    else
      described_class.new
    end
  end

  context 'methods' do
    it { is_expected.to respond_to :persisted? }
    it { is_expected.to respond_to :flag_as_persisted! }
    it { is_expected.to respond_to :created_at }
    it { is_expected.to respond_to :updated_at }
  end

  context 'unpersisted' do
    before do
      allow(DateTime).to receive(:now) { datetime }
    end

    context '#created_at' do
      it 'is nil' do
        expect(subject.created_at).to eq nil
      end
    end

    context '#updated_at' do
      it 'is nil' do
        expect(subject.updated_at).to eq nil
      end
    end

    context '#persisted?' do
      it 'is false' do
        expect(subject).not_to be_persisted
      end
    end

    context '#flag_as_persisted!' do
      context 'when invalid' do
        it 'raises a validation error' do
          expect { subject.flag_as_persisted! }.to raise_error \
            ActiveModel::ValidationError
        end
      end

      context 'when valid' do
        before do
          allow(subject).to receive(:valid?) { true }
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

  context 'persisted' do
    before do
      # setting a value for created_at flags a model as persisted.
      subject.created_at = datetime
      allow(DateTime).to receive(:now) { new_datetime }
    end

    context '#persisted?' do
      it 'is true' do
        expect(subject).to be_persisted
      end
    end

    context '#persisted!' do
      context 'when invalid' do
        # ie a bad update attempt
        it 'raises a validation error' do
          expect { subject.flag_as_persisted! }.to raise_error \
            ActiveModel::ValidationError
        end
      end

      context 'when valid' do
        before do
          allow(subject).to receive(:valid?) { true }
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
