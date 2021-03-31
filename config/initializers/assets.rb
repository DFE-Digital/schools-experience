# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Add GOVUK image asset path
Rails.application.config.assets.paths << Rails.root.join("node_modules", "govuk-frontend", "govuk", "assets", "images")

# Add GOVUK font asset path
Rails.application.config.assets.paths << Rails.root.join("node_modules", "govuk-frontend", "govuk", "assets", "fonts")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
