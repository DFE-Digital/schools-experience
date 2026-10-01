# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# GOV.UK Frontend ships its fonts and images under this directory. Adding it to
# the Propshaft load path lets Propshaft digest them and rewrite the /fonts/...
# and /images/... url() references emitted by govuk-frontend's Sass (which uses
# $govuk-assets-path: "/") to digested /assets/... paths.
Rails.application.config.assets.paths << Rails.root.join("node_modules", "govuk-frontend", "dist", "govuk", "assets")
