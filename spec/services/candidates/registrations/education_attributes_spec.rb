require 'rails_helper'

describe Candidates::Registrations::EducationAttributes do
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
        expect(subject.attributes).to eq(
          "degree_stage" => "I don't have a degree and am not studying for one",
          "degree_stage_explaination" => "",
          "degree_subject" => "Not applicable",
          "created_at" => current_time,
          "updated_at" => current_time
        )
      end
    end
  end

  context 'with new session' do
    let :session do
      FactoryBot.build(
        :registration_session,
        :with_education,
        current_time: current_time
      ).to_h
    end

    context '#attributes' do
      it 'returns the correct attributes' do
        expect(subject.attributes).to eq(
          "degree_stage" => "Other",
          "degree_stage_explaination" => "Khan academy, level 3",
          "degree_subject" => "Bioscience",
          "created_at" => current_time,
          "updated_at" => current_time
        )
      end
    end
  end

  context 'with session without education attributes' do
    let :session do
      {}
    end

    context '#attributes' do
      it 'returns an empty hash' do
        expect(subject.attributes).to be nil
      end
    end
  end
end
