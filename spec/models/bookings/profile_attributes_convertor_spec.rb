require 'rails_helper'

RSpec.describe Bookings::ProfileAttributesConvertor, type: :model do
  subject { described_class.new({}) } # Default empty profile

  describe "#profile_attrs" do
    context 'with completed profile' do
      let(:completed_attrs) do
        build(:school_profile, :completed).attributes
      end

      subject do
        described_class.new(completed_attrs).attributes
      end

      it { is_expected.to include(dbs_requires_check: true) }
      it { is_expected.to include(dbs_policy_details: 'Must have recent dbs check') }

      it { is_expected.to include(individual_requirements: /Must be applying to or have applied to our, or a partner school/) }
      it { is_expected.to include(individual_requirements: /Must have a degree/) }
      it { is_expected.to include(individual_requirements: /They must live within 8 miles of the school/) }
      it { is_expected.to include(individual_requirements: /Make sure photo is clear/) }
      it { is_expected.to include(individual_requirements: /Some other requirements/) }

      it { is_expected.to include(description_details: 'Horse archery') }
      it { is_expected.to include(dress_code_business: true) }
      it { is_expected.to include(dress_code_cover_tattoos: true) }
      it { is_expected.to include(dress_code_remove_piercings: true) }
      it { is_expected.to include(dress_code_smart_casual: true) }
      it { is_expected.to include(dress_code_other_details: 'Must have nice hat') }
      it { is_expected.to include(admin_contact_email: 'g.chalmers@springfield.edu') }
      it { is_expected.to include(admin_contact_email_secondary: 's.skinner@springfield.edu') }
      it { is_expected.to include(admin_contact_phone: '+441234567890') }
      it { is_expected.to include(primary_phase: true) }
      it { is_expected.to include(secondary_phase: true) }
      it { is_expected.to include(college_phase: true) }
      it { is_expected.to include(key_stage_early_years: true) }
      it { is_expected.to include(key_stage_1: true) }
      it { is_expected.to include(key_stage_2: true) }
      it { is_expected.to include(start_time: '8:15am') }
      it { is_expected.to include(end_time: '4:30pm') }
      it { is_expected.to include(flexible_on_times: true) }
      it { is_expected.to include(flexible_on_times_details: 'We are very accommodating') }
      it { is_expected.to include(experience_details: 'Mostly teaching') }
      it { is_expected.to include(parking_provided: true) }
      it { is_expected.to include(parking_details: 'Plenty of spaces') }
      it { is_expected.to include(teacher_training_info: 'We offer teach training in house') }
      it { is_expected.to include(teacher_training_url: 'https://example.com') }
      it { is_expected.to include(administration_fee_amount_pounds: 123.45) }
      it { is_expected.to include(administration_fee_description: 'General administration') }
      it { is_expected.to include(administration_fee_interval: 'Daily') }
      it { is_expected.to include(administration_fee_payment_method: 'Travelers Cheques') }
      it { is_expected.to include(dbs_fee_amount_pounds: 200.00) }
      it { is_expected.to include(dbs_fee_description: 'DBS check') }
      it { is_expected.to include(dbs_fee_interval: 'One-off') }
      it { is_expected.to include(dbs_fee_payment_method: 'Ethereum') }
      it { is_expected.to include(other_fee_amount_pounds: 444.44) }
      it { is_expected.to include(other_fee_description: 'Owl repellent / other protective gear') }
      it { is_expected.to include(other_fee_interval: 'One-off') }
      it { is_expected.to include(other_fee_payment_method: 'Stamps') }
      it { is_expected.to include(supports_access_needs: true) }
      it { is_expected.to include(access_needs_description: 'Here are some details') }
      it { is_expected.to include(disability_confident: true) }
      it { is_expected.to include(has_access_needs_policy: true) }
      it { is_expected.to include(access_needs_policy_url: 'https://example.com/access-needs-policy') }
    end

    context 'with completed profile with blank fields' do
      let(:model_attrs) do
        model = build(:school_profile, :completed)
        model.dbs_requirement_requires_check = false
        model.dbs_requirement_dbs_policy_details = ''
        model.dbs_requirement_no_dbs_policy_details = ''
        model.candidate_requirement_dbs_requirement = 'never'
        model.candidate_requirements_selection_on_teacher_training_course = false
        model.candidate_requirements_selection_live_locally = false
        model.candidate_requirements_selection_maximum_distance_from_school = false
        model.candidate_requirements_selection_other = false
        model.candidate_requirements_selection_not_on_another_training_course = false
        model.candidate_requirements_selection_has_or_working_towards_degree = false
        model.candidate_requirements_selection_provide_photo_identification = false
        model.description_details = ' '
        model.candidate_experience_detail_disabled_facilities = false
        model.candidate_experience_detail_other_dress_requirements = false
        model.admin_contact_email = ' '
        model.phases_list_primary = false
        model.phases_list_secondary = false
        model.phases_list_college = true
        model.phases_list_secondary_and_college = true
        model.candidate_experience_detail_parking_provided = false
        model.candidate_experience_detail_nearby_parking_details = 'somewhere further away'
        model.experience_outline_provides_teacher_training = false
        model.fees_administration_fees = false
        model.fees_dbs_fees = false
        model.fees_other_fees = false
        model.access_needs_support_supports_access_needs = false

        model.attributes
      end

      subject do
        described_class.new(model_attrs).attributes
      end

      it { is_expected.to include(dbs_requires_check: false) }
      it { is_expected.to include(dbs_policy_details: nil) }
      it { is_expected.to include(individual_requirements: 'None') }
      it { is_expected.to include(description_details: nil) }
      it { is_expected.to include(dress_code_other_details: nil) }
      it { is_expected.to include(admin_contact_email: nil) }
      it { is_expected.to include(admin_contact_email_secondary: nil) }
      it { is_expected.to include(admin_contact_phone: nil) }
      it { is_expected.to include(primary_phase: false) }
      it { is_expected.to include(secondary_phase: true) }
      it { is_expected.to include(college_phase: true) }
      it { is_expected.to include(key_stage_early_years: false) }
      it { is_expected.to include(key_stage_1: false) }
      it { is_expected.to include(key_stage_2: false) }
      it { is_expected.to include(parking_provided: false) }
      it { is_expected.to include(parking_details: 'somewhere further away') }
      it { is_expected.to include(teacher_training_info: nil) }
      it { is_expected.to include(teacher_training_url: nil) }
      it { is_expected.to include(administration_fee_amount_pounds: nil) }
      it { is_expected.to include(administration_fee_description: nil) }
      it { is_expected.to include(administration_fee_interval: nil) }
      it { is_expected.to include(administration_fee_payment_method: nil) }
      it { is_expected.to include(dbs_fee_amount_pounds: nil) }
      it { is_expected.to include(dbs_fee_description: nil) }
      it { is_expected.to include(dbs_fee_interval: nil) }
      it { is_expected.to include(dbs_fee_payment_method: nil) }
      it { is_expected.to include(other_fee_amount_pounds: nil) }
      it { is_expected.to include(other_fee_description: nil) }
      it { is_expected.to include(other_fee_interval: nil) }
      it { is_expected.to include(other_fee_payment_method: nil) }
      it { is_expected.to include(supports_access_needs: false) } # rename this clashed with form model
      it { is_expected.to include(access_needs_description: nil) }
      it { is_expected.to include(disability_confident: nil) }
      it { is_expected.to include(has_access_needs_policy: nil) }
      it { is_expected.to include(access_needs_policy_url: nil) }
    end
  end

  describe '#phase_ids' do
    before { @early_years = create(:bookings_phase, :early_years) }
    before { @primary = create(:bookings_phase, :primary) }
    before { @secondary = create(:bookings_phase, :secondary) }
    before { @college = create(:bookings_phase, :college) }
    let(:attrs) { build(:school_profile, :completed).attributes }
    subject { described_class.new(attrs).phase_ids }

    it { is_expected.to include(@early_years.id) }
    it { is_expected.to include(@primary.id) }
    it { is_expected.to include(@secondary.id) }
    it { is_expected.to include(@college.id) }
  end
end
