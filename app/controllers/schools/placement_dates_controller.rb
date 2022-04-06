class Schools::PlacementDatesController < Schools::BaseController
  before_action :set_placement_date, only: %w[edit]
  include Schools::PlacementDates::Wizard

  def index
    @placement_dates = current_school
      .bookings_placement_dates
      .published
      .bookable_date
      .in_date_order
      .eager_load(:bookings_school, :placement_date_subjects, :subjects)
  end

  def new
    @placement_date = current_school
      .bookings_placement_dates
      .new
  end

  def create
    @placement_date = current_school
      .bookings_placement_dates
      .new(new_placement_date_params)

    if @placement_date.valid?
      @placement_date.save
      recurrences_session[:recurrences] = [@placement_date.date]

      next_step @placement_date
    else
      render :new
    end
  end

  def edit
    next_step @placement_date
  end

  def close
    confirmed = ActiveModel::Type::Boolean.new.cast(
      params["schools_placement_dates_close_confirmation_form"]["confirmed"]
    )

    current_school.bookings_placement_dates.find(params[:placement_date_id]).update!(active: false) if confirmed

    redirect_to schools_placement_dates_path
  end

  def close_confirmation
    @placement_date = current_school.bookings_placement_dates.find(params[:placement_date_id])

    @confirmation = Schools::PlacementDates::CloseConfirmationForm.new
  end

private

  def school_supports_subjects?
    @current_school.has_secondary_phase?
  end

  def set_placement_date
    @placement_date = current_school
      .bookings_placement_dates
      .find(params[:id])
  end

  def new_placement_date_params
    params.require(:bookings_placement_date).permit(:date, :recurring)
  end
end
