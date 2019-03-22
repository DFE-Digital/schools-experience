module ApplicationHelper
  def page_title
    [
      content_for(:page_title).presence,
      'DfE School Experience'
    ].compact.join ' | '
  end

  def page_title=(title)
    content_for :page_title do
      title
    end
  end
end
