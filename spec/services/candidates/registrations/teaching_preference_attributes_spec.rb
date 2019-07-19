require 'rails_helper'

describe Candidates::Registrations::TeachingPreferenceAttributes do
  let! :current_time do
    DateTime.current
  end

  subject { described_class.new session }

  context 'with legacy session' do
    let :session do
      FactoryBot.build(
        :registration_session,
        current_time: current_time
      ).to_h
    end

    context '#attributes' do
      it 'returns the correct attributes' do
        expect(subject.attributes).to eq \
          "teaching_stage"        => "I’m very sure and think I’ll apply",
          "subject_first_choice"  => "Maths",
          "subject_second_choice" => "Physics",
          "created_at"            => current_time,
          "updated_at"            => current_time
      end
    end
  end

  context 'with new session' do
    let :session do
      FactoryBot.build(
        :registration_session,
        :with_teaching_preference,
        current_time: current_time
      ).to_h
    end

    context '#attributes' do
      it 'returns the correct attributes' do
        expect(subject.attributes).to eq \
          "teaching_stage" => "I’m very sure and think I’ll apply",
          "subject_first_choice" => "Astronomy",
          "subject_second_choice" => "History",
          "created_at"            => current_time,
          "updated_at"            => current_time
      end
    end
  end

  context 'with session without teaching_preference_attributes' do
    let :session do
      {}
    end

    context '#attributes' do
      it 'returns an nil' do
        expect(subject.attributes).to be nil
      end
    end
  end
end
