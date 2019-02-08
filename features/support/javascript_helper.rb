def opaquify_inputs?
  page.driver.is_a?(Capybara::Selenium::Driver)
end

def make_inputs_opaque
  script = <<~SCRIPT
    document
      .querySelectorAll("input[type='checkbox'], input[type='radio']")
      .forEach(
        function(element) {element.setAttribute("style", "opacity: 1;")}
      );
  SCRIPT

  page.execute_script(script)
end
