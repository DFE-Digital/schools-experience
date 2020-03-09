module BackToTopHelper
  def back_to_top_link
    svg_icon = tag.svg \
      class: 'app-back-to-top__icon',
      xmlns: 'http://www.w3.org/2000/svg',
      width: '13',
      height: '17',
      viewBox: '0 0 13 17' do
      tag.path \
        fill: 'currentColor',
        d: 'M6.5 0L0 6.5 1.4 8l4-4v12.7h2V4l4.3 4L13 6.4z'
    end

    link_to '#', class: 'govuk-link govuk-link--no-visited-state back-to-top' do
      safe_join [svg_icon, 'Back to top'], ' '
    end
  end
end
