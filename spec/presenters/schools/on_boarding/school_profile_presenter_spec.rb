require 'rails_helper'

describe Schools::OnBoarding::SchoolProfilePresenter do
  subject { described_class.new profile }

  let! :school do
    FactoryBot.create :bookings_school, :full_address, urn: 123_456
  end

  context '#school_name' do
    let :profile do
      FactoryBot.create :school_profile, bookings_school: school
    end

    it "returns the school's name" do
      expect(subject.school_name).to eq school.name
    end
  end

  context '#school_address' do
    let :profile do
      FactoryBot.build :school_profile, bookings_school: school
    end

    it "returns the school's address" do
      expect(subject.school_address).to \
        match(/\d{1,} Something Street, \d{1,} Something area, \d{1,} Something area, \d{1,} Something town, \d{1,} Something county, M\d{1,} 2JF/)
    end
  end

  context '#school_email' do
    let :profile do
      FactoryBot.build :school_profile, bookings_school: school
    end

    it "returns the school's contact email" do
      expect(subject.school_email).to eq school.contact_email
    end
  end

  context '#fees' do
    context 'with no fees' do
      let :profile do
        FactoryBot.build :school_profile
      end

      it 'returns no' do
        expect(subject.fees).to eq 'No'
      end
    end

    context 'with fees' do
      context 'with administration_fees' do
        let :profile do
          FactoryBot.build \
            :school_profile,
            :with_administration_fee,
            fees_administration_fees: true
        end

        it 'returns the administration fee' do
          expect(subject.fees).to eq 'Yes - £123.45 daily administration fee'
        end
      end

      context 'with dbs_fees' do
        let :profile do
          FactoryBot.build :school_profile, :with_dbs_fee, fees_dbs_fees: true
        end

        it 'returns the dbs fee' do
          expect(subject.fees).to eq 'Yes - £200.00 one-off dbs fee'
        end
      end

      context 'with other_fees' do
        let :profile do
          FactoryBot.build \
            :school_profile,
            :with_other_fee,
            fees_other_fees: true
        end

        it 'returns the other fee' do
          expect(subject.fees).to eq 'Yes - £444.44 one-off other fee'
        end
      end
    end
  end

  context '#dbs_check' do
    let :profile do
      build :school_profile
    end

    before { profile.dbs_requirement = dbs_requirement }

    context 'when required' do
      let :dbs_requirement do
        build :dbs_requirement
      end

      it 'returns the correct details' do
        expect(subject.dbs_check).to eq 'Yes - Must have recent dbs check'
      end
    end

    context 'when inschool' do
      let :dbs_requirement do
        build :dbs_requirement, dbs_policy_conditions: 'inschool', dbs_policy_details_inschool: 'requires recent dbs check'
      end

      it 'returns the correct details' do
        expect(subject.dbs_check).to eq 'Yes - when in school - requires recent dbs check'
      end
    end

    context 'when not required' do
      context 'when additional details provide' do
        let :dbs_requirement do
          build :dbs_requirement,
            dbs_policy_conditions: 'notrequired', no_dbs_policy_details: 'Some details'
        end

        it 'returns the correct details' do
          expect(subject.dbs_check).to eq \
            'No - Candidates will be accompanied at all times when in school - Some details'
        end
      end

      context 'when additional details not provide' do
        let :dbs_requirement do
          build :dbs_requirement, dbs_policy_conditions: 'notrequired'
        end

        it 'returns the correct details' do
          expect(subject.dbs_check).to eq \
            'No - Candidates will be accompanied at all times when in school'
        end
      end
    end
  end

  context '#individual_requirements' do
    context 'without requirements' do
      let :profile do
        FactoryBot.build :school_profile
      end

      it 'returns no' do
        expect(subject.individual_requirements).to eq 'None'
      end
    end

    context 'with requirements' do
      let :profile do
        FactoryBot.build :school_profile,
          :with_candidate_requirements_selection
      end

      it 'returns yes with the requirements' do
        [
          /Must be applying to or have applied to our, or a partner school/,
          /Must have a degree/,
          /They must live within 8 miles of the school/,
          /Make sure photo is clear/,
          /Some other requirements/
        ].each do |req|
          expect(subject.individual_requirements).to match(req)
        end
      end
    end
  end

  context '#school_experience_phases' do
    context 'all phases selected' do
      let :profile do
        FactoryBot.build :school_profile, :with_phases
      end

      it 'adds each selected phase to the output' do
        expect(subject.school_experience_phases).to \
          eq 'Primary, secondary, and 16 - 18 years'
      end
    end

    context 'subset of phases selected' do
      let :profile do
        FactoryBot.build :school_profile, :with_only_early_years_phase
      end

      it 'only adds the selected phases' do
        expect(subject.school_experience_phases).to eq 'Primary'
      end
    end
  end

  context '#primary_key_stages_offered?' do
    context 'when offered' do
      let :profile do
        FactoryBot.build \
          :school_profile, :with_phases, phases_list_primary: true
      end

      it 'returns true' do
        expect(subject.primary_key_stages_offered?).to eq true
      end
    end

    context 'when not offered' do
      let :profile do
        FactoryBot.build \
          :school_profile, :with_phases, phases_list_primary: false
      end

      it 'returns false' do
        expect(subject.primary_key_stages_offered?).to eq false
      end
    end
  end

  context '#primary_key_stages' do
    context 'when primary phase not selected' do
      let :profile do
        FactoryBot.build \
          :school_profile, :with_phases, phases_list_primary: false
      end

      it 'returns None' do
        expect(subject.primary_key_stages).to eq 'None'
      end
    end

    context 'when primary phase selected' do
      let :profile do
        FactoryBot.build \
          :school_profile, :with_phases, :with_key_stage_list
      end

      it 'returns the key stages' do
        expect(subject.primary_key_stages).to \
          eq 'Early years, key stage 1, and key stage 2'
      end
    end
  end

  context '#subjects_offered?' do
    context 'when offered' do
      let :profile do
        FactoryBot.build \
          :school_profile, :with_phases, phases_list_secondary: true
      end

      it 'returns true' do
        expect(subject.subjects_offered?).to eq true
      end
    end

    context 'when not offered' do
      let :profile do
        FactoryBot.build :school_profile
      end

      it 'returns false' do
        expect(subject.subjects_offered?).to eq false
      end
    end
  end

  context '#subjects' do
    context 'when subjects not offered' do
      let :profile do
        FactoryBot.build :school_profile, :with_only_early_years_phase
      end

      it 'returns None' do
        expect(subject.subjects).to eq 'None'
      end
    end

    context 'when subjects offered' do
      let :profile do
        FactoryBot.create :school_profile, :with_phases, :with_subjects
      end

      it 'returns the list of subjects' do
        expect(subject.subjects).to eq profile.subjects.pluck(:name).to_sentence
      end
    end
  end

  context '#descriptions' do
    let :profile do
      FactoryBot.build :school_profile, :with_description
    end

    it 'returns the description' do
      expect(subject.descriptions).to eq 'Horse archery'
    end
  end

  context '#school_experience_details' do
    let :profile do
      FactoryBot.build :school_profile, :with_experience_outline
    end

    it 'returns the school experience details' do
      expect(subject.school_experience_details).to eq 'Mostly teaching'
    end
  end

  context '#dress_code' do
    let :profile do
      FactoryBot.build :school_profile, :with_candidate_dress_code
    end

    it 'returns the selected dress code options' do
      expect(subject.dress_code).to \
        eq "Business dress, cover up tattoos, remove piercings, smart casual, and must have nice hat"
    end
  end

  context '#parking' do
    context 'when parking is offered' do
      let :profile do
        FactoryBot.build :school_profile, :with_candidate_parking_information
      end

      it 'returns parking details' do
        expect(subject.parking).to eq 'Plenty of spaces'
      end
    end

    context 'when parking is not offered' do
      let :profile do
        FactoryBot.build \
          :school_profile, :with_candidate_parking_information, parking: false
      end

      it 'returns nearby parking details' do
        expect(subject.parking).to eq 'Public car park across the street'
      end
    end
  end

  context '#start_time' do
    let :profile do
      FactoryBot.build :school_profile, :with_candidate_experience_schedule
    end

    it 'returns the start time' do
      expect(subject.start_time).to eq '8:15am'
    end
  end

  context '#end_time' do
    let :profile do
      FactoryBot.build :school_profile, :with_candidate_experience_schedule
    end

    it 'returns the end time' do
      expect(subject.end_time).to eq '4:30pm'
    end
  end

  context '#flexible_on_times' do
    context 'when flexible_on_times' do
      let :profile do
        FactoryBot.build :school_profile, \
          :with_candidate_experience_schedule, times_flexible: true
      end

      it 'returns Yes with details' do
        expect(subject.flexible_on_times).to eq 'Yes - We are very accommodating'
      end
    end

    context 'when not flexible_on_times' do
      let :profile do
        FactoryBot.build :school_profile,
          :with_candidate_experience_schedule, times_flexible: false
      end

      it 'returns no' do
        expect(subject.flexible_on_times).to eq 'No'
      end
    end
  end

  context '#admin_contact_email' do
    let :profile do
      FactoryBot.build :school_profile, :with_admin_contact
    end

    it "returns the admin contact's email" do
      expect(subject.admin_contact_email).to eq 'g.chalmers@springfield.edu'
    end
  end

  context '#admin_contact_email_secondary' do
    let :profile do
      FactoryBot.build :school_profile, :with_admin_contact
    end

    it "returns the admin contact's emails" do
      expect(subject.admin_contact_email_secondary).to eq 's.skinner@springfield.edu'
    end
  end

  context '#admin_contact_phone' do
    let :profile do
      FactoryBot.build :school_profile, :with_admin_contact
    end

    it "returns the admin contact's phone" do
      expect(subject.admin_contact_phone).to eq '+441234567890'
    end
  end
end
