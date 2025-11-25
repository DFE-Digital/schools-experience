module FormForHelper
  def form_for(*args, &block)
    options = args.extract_options!
    defaults = { html: { novalidate: true } }
    super(*args << defaults.deep_merge(options), &block)
  end
end
