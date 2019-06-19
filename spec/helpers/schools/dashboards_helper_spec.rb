require 'rails_helper'

describe Schools::DashboardsHelper, type: 'helper' do
  describe '#numbered_circle' do
    let(:text) { '15' }
    let(:circle) { numbered_circle(text) }
    subject { Nokogiri.parse(circle) }

    context 'id' do
      context 'when not set' do
        specify 'should be absent' do
          expect(subject['id']).to be_nil
        end
      end

      context 'when set' do
        let(:id) { 'what-a-nice-circle' }
        let(:circle) { numbered_circle(text, id: id) }
        specify 'should be set to the overridden value' do
          expect(subject.at_css('svg')['id']).to eql(id)
        end
      end
    end

    context 'shape and colour' do
      specify 'should default to a red circle' do
        expect(subject).to have_css('svg > circle.red')
      end

      specify 'should have the correct dimensions' do
        subject.at_css('svg').tap do |svg|
          expect(svg['height']).to eql("30")
          expect(svg['width']).to eql("26")
        end
      end

      context 'overriding colour' do
        custom_colour = 'blue'
        let(:circle) { numbered_circle(15, colour: 'blue') }
        let(:custom_colour) { custom_colour }

        specify "should be a #{custom_colour} circle" do
          expect(subject).to have_css("svg > circle.#{custom_colour}")
        end
      end

      context 'overriding container size' do
        let(:circle) { numbered_circle(15, width: 40, height: 40) }
        specify 'should have the correct dimensions' do
          subject.at_css('svg').tap do |svg|
            expect(svg['height']).to eql("40")
            expect(svg['width']).to eql("40")
          end
        end
      end

      context 'overriding circle size' do
        custom_size = '19'
        let(:custom_size) { custom_size }
        let(:circle) { numbered_circle(20, circle_size: custom_size) }

        specify "should be a #{custom_size}-sized circle" do
          %w{cx cy r}.each do |dimension|
            expect(subject.at_css('svg > circle')[dimension]).to eql(custom_size)
          end
        end
      end
    end

    context 'text' do
      specify 'should contain the supplied text' do
        expect(subject).to have_css("svg > text", text: text)
      end

      specify 'font size defaults to 16px' do
        expect(subject.at_css('svg > text')['font-size']).to eql('16px')
      end

      context 'overriding font-size' do
        let(:fs) { '22px' }
        let(:circle) { numbered_circle(text, font_size: fs) }

        specify "should be sized at the custom size" do
          expect(subject.at_css('svg > text')['font-size']).to eql(fs)
        end
      end
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
        expect(not_onboarded_warning(school)).to eql("Your profile isn't complete")
      end
    end

    context 'when the school has no placement requests' do
      specify 'should return message "You have school experience requests waiting"' do
        expect(not_onboarded_warning(school)).to eql("You have school experience requests waiting")
      end
    end
  end
end
