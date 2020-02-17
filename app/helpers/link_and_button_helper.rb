module LinkAndButtonHelper
  def govuk_link_to(*args, **options, &block)
    classes, options = link_classes(options)
    link_to(*args, link_defaults(classes).deep_merge(options), &block)
  end

  def govuk_button_to(*args, **options, &block)
    classes, options = link_classes(options)
    button_to(*args, link_defaults(classes).deep_merge(options), &block)
  end

  def govuk_back_link(path = :back, text: 'Back', javascript: false, **options)
    if javascript
      options[:data] ||= {}
      options[:data][:controller] = "back-link #{options[:data][:controller]}".strip
    end

    options[:class] = "govuk-back-link #{options[:class]}".strip

    link_to text, path, **options
  end

private

  def link_defaults(classes)
    {
      class: classes.flatten.join(' ').strip,
      data: { module: 'govuk-button' }
    }
  end

  def link_classes(options)
    classes = ['govuk-button'].tap do |c|
      c << 'govuk-button--secondary' if options.delete(:secondary)
      c << 'govuk-button--warning'   if options.delete(:warning)

      custom_classes = options.delete(:class)

      if custom_classes.present?
        c << Array.wrap(custom_classes)
      end
    end

    [classes, options]
  end
end
