require 'rails_helper'

describe Schools::DashboardsHelper, type: 'helper' do
  describe '#numbered_circle' do
    let(:text) { '15' }
    let(:aria_label) { 'upcoming bookings' }
    let(:circle) { numbered_circle(text, aria_label: aria_label) }
    subject { Nokogiri.parse(circle) }

    context 'id' do
      context 'when not set' do
        specify 'should be absent' do
          expect(subject['id']).to be_nil
        end
      end

      context 'when set' do
        let(:id) { 'what-a-nice-circle' }
        let(:circle) { numbered_circle(text, id: id, aria_label: aria_label) }
        specify 'should be set to the overridden value' do
          expect(subject.at_css('div.numbered-circle')['id']).to eql(id)
        end
      end
    end

    specify 'should contain the supplied text' do
      expect(subject).to have_css("div.numbered-circle", text: text)
    end

    specify 'should have the correct aria label' do
      expect(subject.at_css('div.numbered-circle')['aria-label']).to eql(
        "#{text} #{aria_label}"
      )
    end
  end

  describe '#school_enabled_description' do
    subject { school_enabled_description(school) }

    context 'when enabled' do
      let(:school) { build(:bookings_school) }
      specify "should be 'enabled' when enabled is true" do
        expect(subject).to eql('enabled')
      end
    end

    context 'when disabled' do
      let(:school) { build(:bookings_school, :disabled) }
      specify "should be 'disabled' when enabled is false" do
        expect(subject).to eql('disabled')
      end
    end
  end

  context '#show_no_placement_dates_warning?' do
    context 'when availability preference is fixed and dates are available' do
      let(:school) { create(:bookings_school, :with_fixed_availability_preference, :with_placement_dates) }
      subject { show_no_placement_dates_warning?(school) }

      specify 'should be false' do
        expect(subject).to be false
      end
    end

    context 'when availability preference is flexible and dates are available' do
      let(:school) { create(:bookings_school, :with_placement_dates) }
      subject { show_no_placement_dates_warning?(school) }

      specify 'should be false' do
        expect(subject).to be false
      end
    end

    context 'when availability preference is fixed and dates are not available' do
      let(:school) { create(:bookings_school, :with_fixed_availability_preference) }
      subject { show_no_placement_dates_warning?(school) }

      specify 'should be true' do
        expect(subject).to be true
      end
    end
  end

  context '#show_no_availability_info_warning?' do
    context 'when availability preference is flexible and availability info present' do
      let(:school) { create(:bookings_school) }
      subject { show_no_availability_info_warning?(school) }

      specify 'should be false' do
        expect(subject).to be false
      end
    end

    context 'when availability preference is fixed and availability info is present' do
      let(:school) { create(:bookings_school, :with_fixed_availability_preference) }
      subject { show_no_availability_info_warning?(school) }

      specify 'should be false' do
        expect(subject).to be false
      end
    end

    context 'when availability preference is not fixed and dates are not available' do
      let(:school) { create(:bookings_school, availability_info: nil) }
      subject { show_no_availability_info_warning?(school) }

      specify 'should be true' do
        expect(subject).to be true
      end
    end
  end

  context '#not_onboarded_warning' do
    let(:school) { create(:bookings_school) }
    context 'when the school has placement requests' do
      let!(:pr) { create(:bookings_placement_request, school: school) }

      specify 'should return message "You profile isn\'t complete"' do
        expect(not_onboarded_warning(school)).to eql("You have school experience requests waiting")
      end
    end

    context 'when the school has no placement requests' do
      specify 'should return message "You have school experience requests waiting"' do
        expect(not_onboarded_warning(school)).to eql("Your profile isn't complete")
      end
    end
  end
end
