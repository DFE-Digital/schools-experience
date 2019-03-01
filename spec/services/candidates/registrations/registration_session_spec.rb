require 'rails_helper'

describe Candidates::Registrations::RegistrationSession do
  let! :date do
    DateTime.now
  end

  before do
    allow(DateTime).to receive(:now) { date }
  end

  context '#initialize' do
    before do
      described_class.new session
    end

    context 'when registration key is not set' do
      let :session do
        {}
      end

      it 'adds the registration key to the session' do
        expect(session).to eq({})
      end
    end

    context 'when registration key is set' do
      let :session do
        { 'some' => 'information' }
      end

      it "doesn't over write the registration key" do
        expect(session).to eq 'some' => 'information'
      end
    end
  end

  context '#save' do
    let :session do
      { 'some' => 'information' }
    end

    let :model do
      Candidates::Registrations::BackgroundCheck.new has_dbs_check: true
    end

    before do
      described_class.new(session).save model
    end

    it 'stores the models attributes under the correct key' do
      expect(
        session['candidates_registrations_background_check']
      ).to eq \
        'has_dbs_check' => true,
        'created_at' => date,
        'updated_at' => date
    end

    it 'doesnt over write other keys' do
      expect(session['some']).to eq 'information'
    end
  end

  context '#fetch' do
    let :session do
      {
        'candidates_registrations_background_check' => {
          'has_dbs_check' => true
        }
      }
    end

    let :model_klass do
      Candidates::Registrations::BackgroundCheck
    end

    let :returned_model do
      described_class.new(session).fetch model_klass
    end

    it 'instantiates and returns the model correctly' do
      expect(returned_model).to be_a model_klass
      expect(returned_model.has_dbs_check).to be true
    end
  end
end
