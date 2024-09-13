# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store, key: '_movie_review_session', secret: Rails.application.credentials.secret_key_base
