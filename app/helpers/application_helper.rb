module ApplicationHelper
  def page_title
    safe_join([
      content_for(:page_title).presence,
      'DfE School Experience'
    ].compact, ' | ')
  end

  def page_title=(title)
    content_for :page_title do
      title
    end
  end

  def site_header_text
    @site_header_text || "Get school experience"
  end

  def breadcrumbs
    content_for(:breadcrumbs)
  end

  def breadcrumbs=(data = {})
    if data.any?
      content_for(:breadcrumbs) do
        content_tag(:nav, class: 'govuk-breadcrumbs') do
          content_tag(:ol, class: 'govuk-breadcrumbs__list') do
            safe_join(
              data.map do |text, path|
                content_tag(:li, class: 'govuk-breadcrumbs__list-item') do
                  if path.present?
                    link_to(text, path, class: 'govuk-breadcrumbs__list--link')
                  else
                    text
                  end
                end
              end
            )
          end
        end
      end
    end
  end

  def in_schools_namespace?
    request.path.start_with?('/schools')
  end

  def summary_row(key, value, change_path = nil, id: nil)
    action = change_path ? link_to('Change', change_path) : ""

    render \
      partial: "shared/list_row",
      locals: { key: key, value: value, action: action, id: id }
  end

  def service_update_last_updated_at
    SERVICE_UPDATE_LAST_UPDATED_AT.to_formatted_s :govuk
  end

  def user_info_and_logout_link
    logout_link = link_to("Logout", logout_schools_session_path)

    greeting = if @current_user.is_a?(OpenIDConnect::ResponseObject::UserInfo)
                 "Welcome #{@current_user.given_name} #{@current_user.family_name}."
               end

    switch_service = link_to("switch service", Rails.configuration.x.oidc_services_list_url)

    safe_join([greeting, logout_link, "or", switch_service].compact, " ")
  end

  def phase_three_release_date
    PHASE_THREE_RELEASE_DATE.to_formatted_s :govuk
  end

  def chat_service
    link_to "online chat service", "https://ta-chat.education.gov.uk/chat/chatstart.aspx?domain=www.education.gov.uk&department=GetIntoTeaching%27,%27new_win%27,%27width=0,height=0%27);return&SID=0"
  end
end
