module Candidates::ResultsHelper
  # This helper is a replacement for (and is heavily influenced by)
  # page_entries_info as provided by Kaminari. However, Instead of attempting
  # to build a subquery itself (which fails due to our reliance on calculated
  # columns) it uses the `#total_count` method provided by the supplied
  # Candidates:::SchoolSearch object
  def school_results_info(school_search)
    entry_name = "result".pluralize(school_search.total_count)

    if school_search.results.total_pages < 2
      t(
        'helpers.page_entries_info.one_page.display_entries',
        entry_name: entry_name,
        count: school_search.total_count
      )
    else
      t(
        'helpers.page_entries_info.more_pages.display_entries',
        entry_name: entry_name,
        first: school_search.results.offset_value + 1,
        last: [
          school_search.results.offset_value + school_search.results.limit_value,
          school_search.total_count
        ].min,
        total: school_search.total_count
      )
    end
  end
end
