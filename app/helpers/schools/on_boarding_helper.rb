module Schools::OnBoardingHelper
  def task_row(task, path, status)
    tag.div(class: "govuk-summary-list__row") do
      safe_join([
        tag.dt(class: "govuk-summary-list__key") do
          task_link(task, path, status)
        end,
        tag.dd(class: "govuk-summary-list__actions") { task_tag(status) }
      ])
    end
  end

  def task_link(task, path, status)
    if status.in?(%i[cannot_start_yet not_applicable])
      tag.span(task)
    else
      link_to(task, path)
    end
  end

  def task_tag(status)
    return nil if status == :cannot_start_yet

    color = case status
            when :not_applicable
              "blue"
            when :complete
              "green"
            else
              "grey"
            end

    tag.strong(status.to_s.humanize, class: "govuk-tag govuk-tag--#{color}")
  end
end
