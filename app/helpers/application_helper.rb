module ApplicationHelper
  def page_title
    safe_join([
      content_for(:page_title).presence,
      'Get school experience',
      'GOV.UK'
    ].compact, ' - ')
  end

  def page_title=(title)
    content_for :page_title do
      title
    end
  end

  def page_heading(heading_txt = nil, **options, &block)
    options[:class] ||= 'govuk-heading-l'
    title = heading_txt || capture(&block)

    self.page_title = title
    tag.h1(title, **options)
  end

  def breadcrumbs
    content_for(:breadcrumbs)
  end

  def breadcrumbs=(data = {})
    if data.any?
      content_for(:breadcrumbs) do
        tag.nav(class: 'govuk-breadcrumbs') do
          tag.ol(class: 'govuk-breadcrumbs__list') do
            safe_join(
              data.map do |text, path|
                tag.li(class: 'govuk-breadcrumbs__list-item') do
                  if path.present?
                    link_to(text, path, class: 'govuk-breadcrumbs__list--link')
                  else
                    text
                  end
                end
              end,
              "\n"
            )
          end
        end
      end
    end
  end

  def in_schools_namespace?
    request.path.start_with?('/schools')
  end

  def summary_row(key, value, change_path = nil, change_text = 'Change', id: nil, show_action: true)
    action = show_action && summary_row_link(key, change_path, change_text)

    render \
      partial: "shared/list_row",
      locals: { key: key, value: value, action: action, id: id }
  end

  def summary_row_link(key, path, text)
    return "" unless path

    link_to text, path, 'aria-label': "#{text} #{key}"
  end

  def current_candidate_info_and_logout_link(candidate)
    logout_link = link_to("Logout", candidates_signout_path)

    greeting = "Welcome #{candidate.full_name}"

    safe_join([greeting, logout_link].compact, " ")
  end

  def current_user_info_and_logout_link(user)
    logout_link = link_to("Logout", logout_schools_session_path)

    greeting = if valid_user?(user)
                 "Welcome #{current_user_full_name user}"
               end

    safe_join([greeting, logout_link].compact, " ")
  end

  def current_user_full_name(user)
    return 'Unknown' unless valid_user?(user)

    [user.given_name, user.family_name].join(' ')
  end

  def chat_service
    link_to "online chat service", "https://getintoteaching.education.gov.uk/#talk-to-us"
  end

  def feedback_path
    if in_schools_namespace?
      new_schools_feedback_path
    else
      new_candidates_feedback_path
    end
  end

  def pagination_bar(query)
    tag.div class: 'pagination-info higher' do
      tag.div(page_entries_info(query), class: 'pagination-slice') +
        paginate(query)
    end
  end

  def pagination_lower(query)
    tag.div class: 'pagination-info lower' do
      paginate query
    end
  end

  def site_header_path
    if in_schools_namespace?
      schools_dashboard_path
    else
      root_path
    end
  end

private

  def valid_user?(user)
    user.is_a?(User) || user.is_a?(UserInfoDecorator)
  end
end
