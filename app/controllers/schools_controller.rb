class SchoolsController < ApplicationController
  include DFEAuthentication

  def show
    @signin_deactivated, @signin_message = parse_env_var
  end

private

  def parse_env_var
    if env_var.in? %w(1 true yes)
      true
    elsif env_var.in? %w(0 false no)
      false
    elsif env_var.present?
      [true, env_var]
    else
      false
    end
  end

  def env_var
    ENV['DFE_SIGNIN_DEACTIVATED'].to_s
  end

  def show_candidate_alert_notification?
    false
  end
end
