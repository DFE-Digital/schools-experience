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
end
