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
end
