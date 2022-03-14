require 'rails_helper'

RSpec.describe Candidates::PlacementPresenter do
  let(:placement_request) { create(:placement_request) }
  subject { described_class.new(placement_request) }

  describe '#date' do
    context 'when placement is booked' do
      let(:placement_request) { create(:placement_request, :booked) }

      it 'returns the booked date in govuk format' do
        expect(subject.date).to eq(placement_request.booking.date.to_formatted_s(:govuk))
      end
    end

    context 'when booking is in progress' do
      let(:placement_request) { create(:placement_request) }

      it 'returns "Pending"' do
        expect(subject.date).to eq('Pending')
      end
    end

    context 'when school has not processed the placement request' do
      it 'returns "Pending"' do
        expect(subject.date).to eq('Pending')
      end
    end
  end

  describe '#status' do
    context 'when school has not processed the placement request' do
      context 'when the request is Flagged' do
        let(:candidate) { create(:recurring_candidate) }

        let(:placement_request) { create(:placement_request, candidate: candidate) }

        it 'returns Pending' do
          expect(placement_request.status).to eq('Flagged')
          expect(subject.status).to eq('Pending')
        end
      end

      context 'when the request is Under consideration' do
        let(:placement_request) { create(:placement_request, :under_consideration) }

        it 'returns Pending' do
          expect(placement_request.status).to eq('Under consideration')
          expect(subject.status).to eq('Pending')
        end
      end

      context 'when the request is Viewed' do
        let(:placement_request) { create(:placement_request, :viewed) }

        it 'returns Pending' do
          expect(placement_request.status).to eq('Viewed')
          expect(subject.status).to eq('Pending')
        end
      end

      context 'when the request is New' do
        it 'returns Pending' do
          expect(placement_request.status).to eq('New')
          expect(subject.status).to eq('Pending')
        end
      end
    end

    context 'when school has processed the placement request' do
      context 'when placement is booked' do
        context 'when attended' do
          let(:placement_request) { create(:placement_request, :with_attended_booking) }

          it 'returns the Attended' do
            expect(subject.status).to eq('Attended')
          end
        end

        context 'when not attended' do
          let(:placement_request) { create(:placement_request, :with_unattended_booking) }

          it 'returns Not attended' do
            expect(subject.status).to eq('Not attended')
          end
        end
      end

      context 'when the booking is cancelled by the school' do
        let(:placement_request) { create(:placement_request) }
        before do
          create(:bookings_booking, :accepted, :cancelled_by_school, bookings_placement_request: placement_request)
        end

        it 'returns the placement request status' do
          expect(placement_request.status).to eq('School cancellation')
          expect(subject.status).to eq(placement_request.status)
        end
      end

      context 'when the booking is cancelled by the candidate' do
        let(:placement_request) { create(:placement_request) }
        before do
          create(:bookings_booking, :accepted, :cancelled_by_candidate, bookings_placement_request: placement_request)
        end

        it 'returns the placement request status' do
          expect(placement_request.status).to eq('Candidate cancellation')
          expect(subject.status).to eq(placement_request.status)
        end
      end

      context 'when the placement request is cancelled by the candidate' do
        let(:placement_request) { create(:placement_request, :cancelled) }

        it 'returns the placement request status' do
          expect(placement_request.status).to eq('Withdrawn')
          expect(subject.status).to eq(placement_request.status)
        end
      end

      context 'when the placement request is cancelled by the school' do
        let(:placement_request) { create(:placement_request, :cancelled_by_school) }

        it 'returns the placement request status' do
          expect(placement_request.status).to eq('Rejected')
          expect(subject.status).to eq(placement_request.status)
        end
      end

      context 'when the placement request is expired' do
        let(:placement_request) { create(:placement_request, :with_a_fixed_date_in_the_recent_past) }

        it 'returns the placement request status' do
          expect(placement_request.status).to eq('Expired')
          expect(subject.status).to eq(placement_request.status)
        end
      end
    end
  end

  describe '#status_tag_colour' do
    it 'returns a govuk tag colour css class' do
      allow(subject).to receive(:status).and_return('Withdrawn')

      expect(subject.status_tag_colour).to eq('govuk-tag--orange')
    end
  end

  describe '#placement_action' do
    let(:placement_request) { create(:placement_request, booking: booking) }

    context 'when placement is booked' do
      context 'when attended but not reviewed' do
        let(:booking) { create(:bookings_booking, :accepted, :attended) }

        it 'returns :review' do
          expect(subject.placement_action).to eq(:review)
        end
      end

      context 'when attended and reviewed' do
        let(:booking) { create(:bookings_booking, :accepted, :attended, :with_candidates_feedback) }

        it 'returns nil' do
          expect(subject.placement_action).to be_nil
        end
      end

      context 'when placement is in the future' do
        let(:booking) { create(:bookings_booking, :accepted) }

        it 'returns :cancel' do
          expect(subject.placement_action).to eq(:cancel)
        end
      end
    end

    context 'when the placement is pending' do
      let(:booking) { nil }

      it 'returns :cancel' do
        expect(subject.placement_action).to eq(:cancel)
      end
    end
  end
end
