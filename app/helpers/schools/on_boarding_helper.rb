module Schools::OnBoardingHelper
  def task_row(task, path, status, optional: false)
    tag.div(class: "govuk-summary-list__row") do
      safe_join([
        tag.dt(class: "govuk-summary-list__key") do
          safe_join([
            task_link(task, path, status),
            (tag.span("(optional)", class: "optional") if optional)
          ])
        end,
        tag.dd(class: "govuk-summary-list__actions") { task_tag(status) }
      ])
    end
  end

  def task_link(task, path, status)
    if status.in?(%i(cannot_start_yet not_applicable))
      tag.span(task)
    else
      link_to(task, path)
    end
  end

  def task_tag(status)
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
