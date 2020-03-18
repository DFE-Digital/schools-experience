require 'rails_helper'

describe Bookings::Gitis::FilterBuilder, type: :model do
  let(:filter) { described_class.new 'fname', 'tester' }
  subject { filter.to_s }

  describe '.new' do
    it { is_expected.to eq "fname eq 'tester'" }
  end

  describe 'custom operator' do
    let(:filter) { described_class.new 'fname', 'tester', :ne }
    it { is_expected.to eq "fname ne 'tester'" }
  end

  describe 'serializing values' do
    context 'with a string' do
      let(:filter) { described_class.new 'fname', 'tester' }
      it { is_expected.to eq "fname eq 'tester'" }
    end

    context 'with a true' do
      let(:filter) { described_class.new 'accepted_tandc', true }
      it { is_expected.to eq "accepted_tandc eq true" }
    end

    context 'with a false' do
      let(:filter) { described_class.new 'accepted_tandc', false }
      it { is_expected.to eq "accepted_tandc eq false" }
    end

    context 'with a nil' do
      let(:filter) { described_class.new 'parentid', nil }
      it { is_expected.to eq "parentid eq null" }
    end

    context 'with an integer' do
      let(:filter) { described_class.new 'age', 0 }
      it { is_expected.to eq "age eq 0" }
    end

    context 'with a a float' do
      let(:filter) { described_class.new 'height', 1.8 }
      it { is_expected.to eq "height eq 1.8" }
    end
  end

  describe 'chaining' do
    describe 'and' do
      subject { filter.and('lname', 'smith').to_s }
      it { is_expected.to eq "fname eq 'tester' and lname eq 'smith'" }
    end

    describe 'and with another filter' do
      subject { filter.and('lname', 'smith', :ne).to_s }
      it { is_expected.to eq "fname eq 'tester' and lname ne 'smith'" }
    end

    describe 'or' do
      subject { filter.or('lname', 'smith').to_s }
      it { is_expected.to eq "fname eq 'tester' or lname eq 'smith'" }
    end

    describe 'or with another filter' do
      subject { filter.or('lname', 'smith', :ne).to_s }
      it { is_expected.to eq "fname eq 'tester' or lname ne 'smith'" }
    end

    describe 'complex chain' do
      subject { filter.and('lname', 'smith').or('age', 90, :gte).to_s }
      it do
        is_expected.to eq \
          "fname eq 'tester' and lname eq 'smith' or age gte 90"
      end
    end
  end

  describe 'nesting' do
    let(:age) { described_class.new 'age', 90, :gte }
    let(:nested) { described_class.new filter }

    subject { nested.to_s }
    it { is_expected.to eq "(fname eq 'tester')" }

    describe 'chained nesting' do
      subject { filter.and('lname', 'smith').or(age).to_s }
      it do
        is_expected.to eq \
          "fname eq 'tester' and lname eq 'smith' or (age gte 90)"
      end
    end

    describe 'combining nesting' do
      let(:nested) { described_class.new filter.and('lname', 'smith') }
      subject { nested.or(age).to_s }
      it do
        is_expected.to eq \
          "(fname eq 'tester' and lname eq 'smith') or (age gte 90)"
      end
    end
  end
end
