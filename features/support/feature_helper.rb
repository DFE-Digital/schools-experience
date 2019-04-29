def delay_page_load
  if ENV['CUC_DRIVER'].present? || ENV['CUC_PAGE_DELAY'].present?
    sleep Integer(ENV['CUC_PAGE_DELAY'] { 2 })
  end
end
