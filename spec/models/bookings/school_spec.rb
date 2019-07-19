require 'rails_helper'

describe Bookings::School, type: :model do
  describe 'Validation' do
    context 'name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_most(128) }
    end

    context 'fee' do
      it { is_expected.to validate_presence_of(:fee) }
      it { is_expected.to validate_numericality_of(:fee).is_greater_than_or_equal_to(0) }
    end

    context 'availability_info' do
      it { is_expected.to allow_value(nil).for(:availability_info) }
      it { is_expected.to validate_length_of(:availability_info).is_at_least(3) }

      context 'overwriting empty strings before validation' do
        subject { create(:bookings_school) }
        before { subject.update(availability_info: '') }
        specify 'should overwrite empty strings with nil' do
          expect(subject.availability_info).to be_nil
        end
      end
    end

    shared_examples "websites" do |field_name|
      valid_urls = %w{http://www.bbc.co.uk https://bbc.co.uk http://news.bbc.com}
      invalid_urls = [
        "www.bbc.co.uk",
        "lizo.mzimba@bbc.co.uk",
        "ftp://bbc.co.uk",
        "//bbc.co.uk",
        "07865 432 321"
      ]

      subject { Bookings::School.new }

      context field_name do
        context 'valid' do
          valid_urls.each do |valid_url|
            it { should allow_value(valid_url).for(field_name) }
          end
        end

        context 'invalid' do
          invalid_urls.each do |invalid_url|
            it { should_not allow_value(invalid_url).for(field_name) }
          end
        end
      end
    end

    include_examples "websites", :website
    include_examples "websites", :teacher_training_website

    context 'contact_email' do
      valid_addresses = %w{hello@bbc.co.uk hi.there@bbc.com}
      invalid_addresses = [
        "www.bbc.co.uk",
        "0161 123 4567",
        "address including whitespace@something.org",
        "this@does@not.work.com",
        "@twitter_handle2",
        "trailing@",
        "nodomain@.com",
        "trailingdot@somewhere."
      ]

      context 'valid' do
        valid_addresses.each do |valid_address|
          it { should allow_value(valid_address).for(:contact_email) }
        end
      end

      context 'invalid' do
        invalid_addresses.each do |invalid_address|
          it { should_not allow_value(invalid_address).for(:contact_email) }
        end
      end
    end
  end

  describe 'Relationships' do
    it do
      is_expected.to(
        have_one(:school_profile)
          .with_foreign_key(:bookings_school_id)
      )
    end

    specify do
      is_expected.to(
        have_many(:bookings_schools_subjects)
          .class_name("Bookings::SchoolsSubject")
          .with_foreign_key(:bookings_school_id)
          .inverse_of(:bookings_school)
      )
    end

    specify do
      is_expected.to(
        have_many(:subjects)
          .through(:bookings_schools_subjects)
          .class_name("Bookings::Subject")
          .source(:bookings_subject)
      )
    end

    specify do
      is_expected.to(
        have_many(:bookings_schools_phases)
          .class_name("Bookings::SchoolsPhase")
          .with_foreign_key(:bookings_school_id)
          .inverse_of(:bookings_school)
      )
    end

    specify do
      is_expected.to(
        have_many(:phases)
          .through(:bookings_schools_phases)
          .class_name("Bookings::Phase")
          .source(:bookings_phase)
      )
    end

    specify do
      is_expected.to(
        belong_to(:school_type)
          .with_foreign_key(:bookings_school_type_id)
          .class_name("Bookings::SchoolType")
      )
    end

    specify do
      is_expected.to(
        have_many(:bookings_placement_dates)
          .with_foreign_key(:bookings_school_id)
          .class_name('Bookings::PlacementDate')
          .dependent(:destroy)
      )
    end

    specify do
      is_expected.to(
        have_many(:bookings_placement_requests)
          .with_foreign_key(:bookings_school_id)
          .class_name('Bookings::PlacementRequest')
          .dependent(:destroy)
      )
    end

    specify do
      is_expected.to(
        have_many(:bookings)
          .with_foreign_key(:bookings_school_id)
          .class_name('Bookings::Booking')
          .dependent(:destroy)
      )
    end

    specify do
      is_expected.to have_one(:profile).class_name("Bookings::Profile")
    end

    specify do
      is_expected.to \
        have_many(:placement_requests)
          .with_foreign_key(:bookings_school_id)
          .class_name('Bookings::PlacementRequest')
          .dependent(:destroy)
    end

    specify do
      is_expected.to \
        have_many(:events)
          .with_foreign_key(:bookings_school_id)
          .dependent(:destroy)
    end
  end

  describe 'Paramterisation' do
    subject { create(:bookings_school) }

    specify do
      expect(subject.to_param).to eq(subject.urn.to_s)
    end
  end

  describe 'Scopes' do
    subject { Bookings::School }

    context 'Full text searching on Name' do
      # provided by FullTextSearch
      it { is_expected.to respond_to(:search_by_name) }
    end

    context 'Geographic searching by Coordinates' do
      # provided by FullTextSearch
      it { is_expected.to respond_to(:close_to) }
    end

    context 'Enabled' do
      let!(:enabled_school) { create(:bookings_school) }
      let!(:disabled_school) { create(:bookings_school, :disabled) }

      it { is_expected.to respond_to(:enabled) }

      specify 'should return enabled schools' do
        expect(subject.enabled).to include(enabled_school)
      end

      specify 'should not return non-enabled schools' do
        expect(subject.enabled).not_to include(disabled_school)
      end
    end

    context 'Filtering' do
      let!(:school_a) { create(:bookings_school) }
      let!(:school_b) { create(:bookings_school) }
      let!(:school_c) { create(:bookings_school) }

      context 'By subject' do
        let!(:maths) { Bookings::Subject.find_by! name: 'Maths' }
        let!(:physics) { Bookings::Subject.find_by! name: "Physics" }
        let!(:chemistry) { Bookings::Subject.find_by! name: "Chemistry" }
        let!(:biology) { Bookings::Subject.find_by! name: "Biology" }

        before do
          school_a.subjects << [maths, physics]
          school_b.subjects << [maths, chemistry]
          school_c.subjects << [biology]
        end

        context 'when no subjects are supplied' do
          specify 'all schools should be returned' do
            [nil, "", []].each do |empty|
              expect(subject.that_provide(empty)).to include(school_a, school_b, school_c)
            end
          end
        end

        context 'when one or more subjects are supplied' do
          specify 'all schools that match any provided subject are returned' do
            {
              physics              => [school_a],
              maths                => [school_a, school_b],
              chemistry            => [school_b],
              biology              => [school_c],
              [chemistry, biology] => [school_b, school_c],
              [maths, chemistry]   => [school_a, school_b],
              [maths, biology]     => [school_a, school_b, school_c]
            }.each do |subjects, results|
              expect(subject.that_provide(subjects).uniq).to match_array(results)
            end
          end
        end
      end

      context 'By phase' do
        let!(:primary) { create(:bookings_phase, name: "Primary") }
        let!(:secondary) { create(:bookings_phase, name: "Secondary") }
        let!(:college) { create(:bookings_phase, name: "College") }

        before do
          school_a.phases << [primary]
          school_b.phases << [primary, secondary]
          school_c.phases << [college]
        end

        context 'when no phases are supplied' do
          specify 'all schools should be returned' do
            [nil, "", []].each do |empty|
              expect(subject.at_phases(empty)).to include(school_a, school_b, school_c)
            end
          end
        end

        context 'when one or more phases are supplied' do
          specify 'all schools that match any provided phase are returned' do
            {
              primary              => [school_a, school_b],
              secondary            => [school_b],
              college              => [school_c],
              [primary, college]   => [school_a, school_b, school_c],
              [secondary, college] => [school_b, school_c]
            }.each do |phases, results|
              expect(subject.at_phases(phases)).to match_array(results)
            end
          end
        end
      end

      context 'By fees' do
        let!(:school_a) { create(:bookings_school, fee: 0) }
        let!(:school_b) { create(:bookings_school, fee: 20) }
        let!(:school_c) { create(:bookings_school, fee: 40) }

        specify 'should return all schools when no amount provided' do
          [nil, "", []].each do |empty|
            expect(subject.costing_upto(empty)).to include(school_a, school_b, school_c)
          end
        end

        specify 'should return all schools with no fee when amount provided' do
          expect(subject.costing_upto(20)).to include(school_a)
        end

        specify 'should return all schools with a lower equal fee when amount provided' do
          expect(subject.costing_upto(20)).to include(school_a, school_b)
        end

        specify 'should not return schools with a higher fee than provided amount' do
          expect(subject.costing_upto(20)).not_to include(school_c)
        end
      end
    end

    context 'Availability and placement dates' do
      specify { expect(described_class).to respond_to(:flexible) }
      specify { expect(described_class).to respond_to(:flexible_with_description) }
      specify { expect(described_class).to respond_to(:fixed) }
      specify { expect(described_class).to respond_to(:fixed_with_available_dates) }
      specify { expect(described_class).to respond_to(:with_availability) }

      specify { expect(described_class.new).to have_db_column(:availability_info).of_type(:text) }
      specify { expect(described_class.new).to have_db_column(:availability_preference_fixed).of_type(:boolean).with_options(default: false, null: false) }

      let!(:flexible_with_description) { create(:bookings_school) }
      let!(:flexible_without_description) { create(:bookings_school, availability_info: nil) }
      let!(:fixed_without_dates) { create(:bookings_school, :with_fixed_availability_preference) }
      let!(:fixed_with_dates) { create(:bookings_school, :with_fixed_availability_preference) }

      let!(:inactive_date) { create(:bookings_placement_date, bookings_school: fixed_without_dates, active: false) }
      let!(:active_date) { create(:bookings_placement_date, bookings_school: fixed_with_dates) }

      context '.flexible' do
        subject { described_class.flexible }

        specify 'should include schools that offer flexible dates' do
          expect(subject).to include(flexible_with_description, flexible_without_description)
        end

        specify 'should not include schools that offer fixed dates' do
          expect(subject).not_to include(fixed_with_dates, fixed_without_dates)
        end
      end

      context '.flexible_with_description' do
        subject { described_class.flexible_with_description }

        specify 'should include schools that offer flexible_dates with availability_description' do
          expect(subject).to include(flexible_with_description)
        end

        specify 'should not include schools that offer flexible_dates without availability_description' do
          expect(subject).not_to include(flexible_without_description)
        end

        specify 'should not include schools that offer fixed dates' do
          expect(subject).not_to include(fixed_with_dates)
          expect(subject).not_to include(fixed_without_dates)
        end
      end

      context '.fixed' do
        subject { described_class.fixed }

        specify 'should include schools that offer fixed dates' do
          expect(subject).to include(fixed_with_dates, fixed_without_dates)
        end

        specify 'should not include schools that offer flexible dates' do
          expect(subject).not_to include(flexible_with_description, flexible_without_description)
        end
      end

      context '.fixed_with_available_dates' do
        subject { described_class.fixed_with_available_dates }
        specify 'should include schools that offer fixed dates and have available dates' do
          expect(subject).to include(fixed_with_dates)
        end

        specify 'should not include schools that offer fixed dates but have no available dates' do
          expect(subject).not_to include(fixed_without_dates)
        end
      end

      context '.with_availability' do
        subject { described_class.with_availability }

        specify 'should include schools that are either flexible or fixed with available dates' do
          expect(subject).to include(flexible_with_description, fixed_with_dates)
        end

        specify 'should not include schools that are fixed with no available dates' do
          expect(subject).not_to include(fixed_without_dates)
        end

        specify 'should not include schools that are flexible with no availability_description' do
          expect(subject).not_to include(flexible_without_description)
        end
      end
    end
  end

  describe 'Methods' do
    describe '#has_availability?' do
      context 'when flexible' do
        subject { build(:bookings_school) }
        it { is_expected.to have_availability }
      end

      context 'when fixed with no dates' do
        subject { build(:bookings_school, :with_fixed_availability_preference) }
        it { is_expected.not_to have_availability }
      end

      context 'when fixed with no dates' do
        subject { create(:bookings_school, :with_fixed_availability_preference) }
        let!(:available_date) do
          create(:bookings_placement_date, date: 1.week.from_now, bookings_school: subject)
        end

        it { is_expected.to have_availability }
      end
    end

    describe '#private_beta?' do
      context 'without profile' do
        subject { create(:bookings_school) }
        it { is_expected.not_to be_private_beta }
      end

      context 'with profile' do
        subject { create(:bookings_profile).school }
        it { is_expected.to be_private_beta }
      end
    end

    describe '#enable!' do
      before do
        allow(Event).to receive(:create!).and_return(true)
      end

      context 'when the school is enabled' do
        subject { create(:bookings_school) }
        before { subject.enable! }

        specify 'the school should remain enabled' do
          expect(subject).to be_enabled
        end

        specify 'should not create a school_disabled event' do
          expect(Event).not_to have_received(:create!)
        end
      end

      context 'when the school is disabled' do
        subject { create(:bookings_school, :disabled) }
        before { subject.enable! }

        specify 'should enable the school' do
          expect(subject).to be_enabled
        end

        specify 'should create a school_enabled event' do
          expect(Event).to have_received(:create!)
            .with(event_type: 'school_enabled', bookings_school: subject)
        end
      end
    end

    describe '#disable!' do
      before do
        allow(Event).to receive(:create!).and_return(true)
      end

      context 'when the school is disabled' do
        subject { create(:bookings_school, :disabled) }
        before { subject.disable! }

        specify 'the school should remain disabled' do
          expect(subject).to be_disabled
        end

        specify 'should not create a school_enabled event' do
          expect(Event).not_to have_received(:create!)
        end
      end

      context 'when the school is enabled' do
        subject { create(:bookings_school) }
        before { subject.disable! }

        specify 'should disable the school' do
          expect(subject).to be_disabled
        end

        specify 'should create a school_disabled event' do
          expect(Event).to have_received(:create!)
            .with(event_type: 'school_disabled', bookings_school: subject)
        end
      end
    end
  end
end
