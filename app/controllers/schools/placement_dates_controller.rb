class Schools::PlacementDatesController < Schools::BaseController
  before_action :set_placement_date, only: %w[edit update]

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

    # if the user hasn't seen the 'select a phase' option on #new, set
    # it here based on their available phases

    if @placement_date.valid?
      unless new_placement_date_params.key?(:supports_subjects)
        @placement_date.assign_attributes(supports_subjects: school_supports_subjects?)
      end

      @placement_date.save
      next_step @placement_date
    else
      render :new
    end
  end

  def edit; end

  def update
    if @placement_date.update(edit_placement_date_params)
      next_step @placement_date
    else
      render :edit
    end
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

  def next_step(placement_date)
    if placement_date.supports_subjects?
      redirect_to new_schools_placement_date_configuration_path(placement_date)
    else
      placement_date.publish
      auto_enable_school
      redirect_to schools_placement_dates_path
    end
  end

  def set_placement_date
    @placement_date = current_school
      .bookings_placement_dates
      .find(params[:id])
  end

  def new_placement_date_params
    params.require(:bookings_placement_date).permit(:date, :duration, :virtual, :supports_subjects, :start_availability_offset, :end_availability_offset)
  end

  def edit_placement_date_params
    params.require(:bookings_placement_date).permit(:duration, :start_availability_offset, :end_availability_offset)
  end
end
