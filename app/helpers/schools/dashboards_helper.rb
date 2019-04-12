module Schools::DashboardsHelper
  def numbered_circle(number, colour: 'red', font_size: "16px", circle_size: 13)
    content_tag(:svg, width: 26, height: 30) do
      safe_join([
        tag(:circle, class: colour, cx: circle_size, cy: circle_size, r: circle_size),
        content_tag(:text, x: "50%", y: "50%", dy: "0.2em", "font-size" => font_size) do
          number.to_s
        end
      ])
    end
  end
end
