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
    end.html_safe
  end

  def expanded_search_radius_header_text
    "0 results found within #{pluralize(params[:distance], 'mile')}"
  end

  def expanded_search_nearby_info_text
    if @search.results.empty?
      capture do
        concat(tag.p { 'Not all schools in your area have signed up to use this website.' })

        concat(tag.p do
          <<~FIND_OUT_MORE
            To find out about arranging school experience with schools who are
            not yet on this website visit #{link_to('Get into teaching', 'https://getintoteaching.education.gov.uk/school-experience/arranging-school-experience-independently')}.
          FIND_OUT_MORE
          .html_safe
        end)
      end
    else
      tag.p { 'However, we did find the following schools nearby:' }.html_safe
    end
  end
end
