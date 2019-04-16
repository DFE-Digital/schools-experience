module Schools
  class BookingsController < Schools::BaseController
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
      Array.new(
        5,
        OpenStruct.new(
          dates_requested: 'Any time during July 2019',
          received_on: '01 January 2019',
          teaching_stage: "I've applied for teacher training",
          teaching_subject: 'Maths',
          status: 'New',
          candidate: Bookings::Gitis::CRM.new('abc123').find(1)
        )
      )
    end

    def booking
      OpenStruct.new(
        urn: 'abc123',
        dates_requested: 'Any time during November 2019',
        received_on: '08 February 2019',
        teaching_stage: "I've applied for teacher training",
        teaching_subject: 'Physics',
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
