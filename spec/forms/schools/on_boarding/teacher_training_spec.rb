require 'rails_helper'

describe Schools::OnBoarding::TeacherTraining, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :provides_teacher_training }
    it { is_expected.to respond_to :teacher_training_details }
    it { is_expected.to respond_to :teacher_training_url }
  end

  context 'validates' do
    it { is_expected.not_to allow_value(nil).for :provides_teacher_training }

    context 'when provides_teacher_training' do
      subject { described_class.new provides_teacher_training: true }
      it { is_expected.to validate_presence_of :teacher_training_details }

      context 'when teacher_training_url is present' do
        invalid_urls = ['javascript:alert("oh no!")//http://example.com'].freeze
        valid_urls = ['https://www.example.com', 'http://example.com'].freeze

        invalid_urls.each do |url|
          it { is_expected.not_to allow_value(url).for :teacher_training_url }
        end

        valid_urls.each do |url|
          it { is_expected.to allow_value(url).for :teacher_training_url }
        end
      end
    end

    context 'when not provides_teacher_training' do
      subject { described_class.new provides_teacher_training: false }
      it { is_expected.not_to validate_presence_of :teacher_training_details }
      it { is_expected.not_to validate_presence_of :teacher_training_url }
    end
  end

  context '.new_from_bookings_school' do
    let :school do
      FactoryBot.build \
        :bookings_school,
        :with_teacher_training_info,
        :with_teacher_training_website,
        teacher_training_provider: true
    end

    subject { described_class.new_from_bookings_school school }

    it "sets provides_teacher_training" do
      expect(subject.provides_teacher_training).to be true
    end

    it "sets teacher_training_details to the school's teacher_training_info" do
      expect(subject.teacher_training_details).to eq school.teacher_training_info
    end

    it "sets the teacher_training_url to the school's teacher_training_website" do
      expect(subject.teacher_training_url).to eq school.teacher_training_website
    end
  end
end
