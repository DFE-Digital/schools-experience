# frozen_string_literal: true

Kaminari.configure do |config|
  config.default_per_page = 15
  # config.max_per_page = nil
  config.window = 4
  config.outer_window = 5
  config.left = 5
  config.right = 5
  # config.page_method_name = :page
  # config.param_name = :page
  # config.params_on_first_page = false
end
