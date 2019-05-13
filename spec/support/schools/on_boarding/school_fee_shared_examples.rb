shared_examples 'a school fee' do
  context '#attributes' do
    it { is_expected.to respond_to :amount_pounds }
    it { is_expected.to respond_to :description }
    it { is_expected.to respond_to :interval }
    it { is_expected.to respond_to :payment_method }
  end

  context '#validations' do
    it { is_expected.to validate_presence_of(:amount_pounds) }

    # Can't do this with shoulda
    context 'amount_pounds' do
      subject { described_class.new amount_pounds: amount }

      before do
        subject.validate
      end

      context 'greater than 9999.99' do
        let :amount do
          10000
        end

        it 'adds an error' do
          expect(subject.errors[:amount_pounds]).to \
            eq ["Must be less than 10000"]
        end
      end

      context 'less than 0' do
        let :amount do
          -4
        end

        it 'add an error' do
          expect(subject.errors[:amount_pounds]).to \
            eq ['Must be greater than 0']
        end
      end

      context '0' do
        let :amount do
          0
        end

        it 'adds an error' do
          expect(subject.errors[:amount_pounds]).to \
            eq ['Must be greater than 0']
        end
      end
    end

    it { is_expected.to validate_presence_of(:description) }

    it do
      is_expected.to validate_inclusion_of(:interval).in_array %w(Daily One-off)
    end

    it { is_expected.to validate_presence_of(:payment_method) }
  end
end
