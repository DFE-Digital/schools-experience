shared_examples 'a feedback' do
  context 'attributes' do
    it do
      is_expected.to have_db_column(:reason_for_using_service)
        .of_type(:integer)
        .with_options(null: false)
    end

    it do
      is_expected.to have_db_column(:rating)
        .of_type(:integer)
        .with_options(null: false)
    end

    it { is_expected.to have_db_column(:improvements).of_type(:text) }
  end

  context 'validations' do
    it do
      is_expected.to validate_presence_of(:reason_for_using_service)
    end

    it { is_expected.to validate_presence_of(:rating) }

    context 'when reason requires explanation' do
      subject { described_class.new(reason_for_using_service: :something_else) }

      it do
        is_expected.to \
          validate_presence_of :reason_for_using_service_explanation
      end
    end

    context 'when reason does not require explanation' do
      it do
        is_expected.not_to \
          validate_presence_of :reason_for_using_service_explanation
      end
    end
  end
end
