# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Third-party stylesheets (vis-timeline), linked explicitly before the app styles.
Rails.application.config.assets.paths << Rails.root.join("vendor/assets/stylesheets")
