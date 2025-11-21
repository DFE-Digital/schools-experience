module FormForHelper
  def form_for(*args, &block)
    options = args.extract_options!
    defaults = { html: { novalidate: true } }
    super(*args << defaults.deep_merge(options), &block)
  end

  def form_for_duplicated_object(*args, &block)
    # NB: we need to deep-duplicate on frozen objects in the schools on-boarding,
    # as they are initialized using active records "composed_of" aggregate macros,
    # which freeze the object and block validations from working
    options = args.extract_options!
    defaults = { html: { novalidate: true } }
    form_for(*(args.deep_dup << defaults.deep_merge(options)), &block)
  end
end
