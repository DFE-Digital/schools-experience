module TextFormattingHelper
  extend ActiveSupport::Concern
  include ActionView::Helpers::TextHelper

  def safe_format(content, opts = {})
    simple_format(strip_tags(content), {}, opts)
  end

  def conditional_format(content)
    if content.to_s.match? %r{\r?\n}
      safe_format content
    else
      content
    end
  end
end
