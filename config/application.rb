require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MovieReview
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'Rangoon'
    config.active_record.default_timezone = :local
    config.active_support.utc_offset = 6.hours + 30.minutes

    # config.eager_load_paths << Rails.root.join("extras")

    config.assets.precompile += %w( movie/show.css )
    config.assets.precompile += %w( movie/shownew.css )
    config.assets.precompile += %w( movie/index.css )
    config.assets.precompile += %w( movie/form.css )

    config.assets.precompile += %w( user/show.css )
    config.assets.precompile += %w( user/index.css )
    config.assets.precompile += %w( user/form.css )

    config.assets.precompile += %w( genre/index.css )
    config.assets.precompile += %w( genre/edit.css )
    config.assets.precompile += %w( genre/search.css )
    config.assets.precompile += %w( year/index.css )
    config.assets.precompile += %w( year/form.css )
    config.assets.precompile += %w( year/show.css )
    config.assets.precompile += %w( year/search.css )

    config.assets.precompile += %w( devise/sign_in.css )
    config.assets.precompile += %w( devise/log_in.css )
    config.assets.precompile += %w( devise/sign_up.css )
    config.assets.precompile += %w( genre/index.css )
    config.assets.precompile += %w( genre/edit.css )

    config.assets.precompile += %w( comment/index.css )
    config.assets.precompile += %w( comment/form.css )

    config.assets.precompile += %w( notification/index.css )

    config.assets.precompile += %w( discussion/index.css )
  end
end
