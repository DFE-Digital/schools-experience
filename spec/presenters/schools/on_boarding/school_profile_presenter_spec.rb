require 'rails_helper'

describe Schools::OnBoarding::SchoolProfilePresenter do
  subject { described_class.new profile }

  let! :school do
    FactoryBot.create :bookings_school, :full_address, urn: 123456
  end

  before do
    FactoryBot.create :bookings_phase, :secondary
    FactoryBot.create :bookings_phase, :college
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

  context '#dbs_check_required' do
    context 'when never' do
      let :profile do
        FactoryBot.build \
          :school_profile,
          candidate_requirement_dbs_requirement: 'never'
      end

      it 'returns No - Never' do
        expect(subject.dbs_check_required).to eq 'No - Never'
      end
    end

    context 'when always' do
      let :profile do
        FactoryBot.build \
          :school_profile,
          candidate_requirement_dbs_requirement: 'always'
      end

      it 'returns Yes - Always' do
        expect(subject.dbs_check_required).to eq 'Yes - Always'
      end
    end

    context 'when sometimes' do
      let :profile do
        FactoryBot.build :school_profile, :with_candidate_requirement
      end

      it 'returns sometimes and the policy' do
        expect(subject.dbs_check_required).to eq 'Yes - Sometimes. Super secure'
      end
    end
  end

  context '#individual_requirements' do
    context 'without requirements' do
      let :profile do
        FactoryBot.build \
          :school_profile, candidate_requirement_requirements: false
      end

      it 'returns no' do
        expect(subject.individual_requirements).to eq 'No'
      end
    end

    context 'with requirements' do
      let :profile do
        FactoryBot.build :school_profile, :with_candidate_requirement
      end

      it 'returns yes with the requirements' do
        expect(subject.individual_requirements).to eq 'Yes - Gotta go fast'
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
          eq 'primary, secondary, and 16 - 18 years'
      end
    end

    context 'subset of phases selected' do
      let :profile do
        FactoryBot.build :school_profile, :with_only_early_years_phase
      end

      it 'only adds the selected phases' do
        expect(subject.school_experience_phases).to eq 'primary'
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
          eq 'early years, key stage 1, and key stage 2'
      end
    end
  end

  context '#secondary_subjects_offered?' do
    context 'when offered' do
      let :profile do
        FactoryBot.build \
          :school_profile, :with_phases, phases_list_secondary: true
      end

      it 'returns true' do
        expect(subject.secondary_subjects_offered?).to eq true
      end
    end

    context 'when not offered' do
      let :profile do
        FactoryBot.build \
          :school_profile, :with_phases, phases_list_secondary: false
      end

      it 'returns false' do
        expect(subject.secondary_subjects_offered?).to eq false
      end
    end
  end

  context '#secondary_subjects' do
    context 'when secondary phase not selected' do
      let :profile do
        FactoryBot.build :school_profile, :with_only_early_years_phase
      end

      it 'returns None' do
        expect(subject.secondary_subjects).to eq 'None'
      end
    end

    context 'when secondary phase selected' do
      let :profile do
        FactoryBot.create \
          :school_profile,
          :with_phases,
          :with_secondary_subjects
      end

      it 'returns the list of secondary subjects' do
        expect(subject.secondary_subjects).to \
          eq profile.secondary_subjects.pluck(:name).to_sentence
      end
    end
  end

  context '#college_subjects_offered?' do
    context 'when offered' do
      let :profile do
        FactoryBot.build \
          :school_profile, :with_phases, phases_list_college: true
      end

      it 'returns true' do
        expect(subject.college_subjects_offered?).to eq true
      end
    end

    context 'when not offered' do
      let :profile do
        FactoryBot.build \
          :school_profile, :with_phases, phases_list_college: false
      end

      it 'returns false' do
        expect(subject.college_subjects_offered?).to eq false
      end
    end
  end

  context '#college_subjects' do
    context 'when college phase not selected' do
      let :profile do
        FactoryBot.build :school_profile, :with_only_early_years_phase
      end

      it 'returns None' do
        expect(subject.college_subjects).to eq 'None'
      end
    end

    context 'when college phase selected' do
      let :profile do
        FactoryBot.create \
          :school_profile,
          :with_phases,
          :with_college_subjects
      end

      it 'returns the list of secondary subjects' do
        expect(subject.college_subjects).to \
          eq profile.college_subjects.pluck(:name).to_sentence
      end
    end
  end

  context '#specialisms' do
    context 'without specialisms' do
      let :profile do
        FactoryBot.build :school_profile
      end

      it 'returns no' do
        expect(subject.specialisms).to eq 'No'
      end
    end

    context 'with specialims' do
      let :profile do
        FactoryBot.build :school_profile, :with_specialism
      end

      it 'returns the specialism' do
        expect(subject.specialisms).to eq 'Yes - Falconry'
      end
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
      FactoryBot.build :school_profile, :with_candidate_experience_detail
    end

    it 'returns the selected dress code options' do
      expect(subject.dress_code).to \
        eq "business dress, cover up tattoos, remove piercings, smart casual, and Must have nice hat"
    end
  end

  context '#parking' do
    context 'when parking is offered' do
      let :profile do
        FactoryBot.build :school_profile, :with_candidate_experience_detail
      end

      it 'returns parking details' do
        expect(subject.parking).to eq 'Plenty of spaces'
      end
    end

    context 'when parking is not offered' do
      let :profile do
        FactoryBot.build \
          :school_profile, :with_candidate_experience_detail, parking: false
      end

      it 'returns nearby parking details' do
        expect(subject.parking).to eq 'Public car park across the street'
      end
    end
  end

  context '#disability_and_access_needs' do
    context 'when disability and access needs facilities not present' do
      let :profile do
        FactoryBot.build :school_profile, :with_candidate_experience_detail
      end

      it 'returns no' do
        expect(subject.disability_and_access_needs).to eq 'No'
      end
    end

    context 'when disability and access needs facilities present' do
      let :profile do
        FactoryBot.build \
          :school_profile,
          :with_candidate_experience_detail,
          disabled_facilities: true
      end

      it 'returns the description' do
        expect(subject.disability_and_access_needs).to \
          eq 'Yes - Full wheelchair access and hearing loops'
      end
    end
  end

  context '#start_time' do
    let :profile do
      FactoryBot.build :school_profile, :with_candidate_experience_detail
    end

    it 'returns the start time' do
      expect(subject.start_time).to eq '8:15am'
    end
  end

  context '#end_time' do
    let :profile do
      FactoryBot.build :school_profile, :with_candidate_experience_detail
    end

    it 'returns the end time' do
      expect(subject.end_time).to eq '4:30pm'
    end
  end

  context '#availability' do
    let :profile do
      FactoryBot.build :school_profile, :with_availability_description
    end

    it 'returns the availability' do
      expect(subject.availability).to eq 'Whenever really'
    end
  end

  context '#admin_contact_full_name' do
    let :profile do
      FactoryBot.build :school_profile, :with_admin_contact
    end

    it "returns the admin contact's name" do
      expect(subject.admin_contact_full_name).to eq 'Gary Chalmers'
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

  context '#admin_contact_phone' do
    let :profile do
      FactoryBot.build :school_profile, :with_admin_contact
    end

    it "returns the admin contact's phone" do
      expect(subject.admin_contact_phone).to eq '+441234567890'
    end
  end
end
