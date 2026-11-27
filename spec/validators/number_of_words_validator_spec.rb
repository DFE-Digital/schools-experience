require 'rails_helper'

describe NumberOfWordsValidator do
  let :errors do
    instance_double(ActiveModel::Errors, add: true)
  end

  let :model do
    Struct.new(:description, :errors).new(description, errors)
  end

  let :validator do
    described_class.new attributes: :description, less_than: 150
  end

  before do
    validator.validate_each model, :description, description
  end

  context 'when less than' do
    context 'when too many words' do
      let :description do
        151.times.map { 'word' }.join(' ')
      end

      it 'adds an error to the correct attribute' do
        expect(errors).to \
          have_received(:add).with(:description, :use_fewer_words, count: 150)
      end
    end

    context 'when correct number of words' do
      let :description do
        149.times.map { 'word' }.join(' ')
      end

      it "doesn't add an error" do
        expect(errors).not_to have_received(:add)
      end
    end
  end
end
