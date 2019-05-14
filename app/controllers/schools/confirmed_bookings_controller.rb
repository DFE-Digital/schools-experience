module Schools
  class ConfirmedBookingsController < Schools::BaseController
    def index
      @bookings = bookings
    end

    def show
      @booking = booking
    end

  private

    # assuming bookings returned from the CRM API will resemble
    # placement requests
    def bookings
      5.times.map do
        OpenStruct.new(
          date: '02 October 2019',
          received_on: '01 January 2019',
          teaching_stage: "I've applied for teacher training",
          teaching_subjects: %w(Biology Physics Maths English Chemistry German),
          status: 'New',
          candidate: Bookings::Gitis::CRM.new('abc123').find(1)
        )
      end
    end

    def booking
      OpenStruct.new(
        urn: 'abc123',
        date: '02 October 2019',
        received_on: '08 February 2019',
        teaching_stage: "I've applied for teacher training",
        status: 'New',
        candidate: Bookings::Gitis::CRM.new('abc123').find(1),

        dbs: 'Yes',
        objectives: 'To learn different teaching styles and what life is like in a classroom.',
        degree_stage: 'Final year',
        degree_subject: 'Maths',
        teaching_subjects: %w(Maths Physics)
      )
    end
  end
end
