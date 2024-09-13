# app/mailers/application_mailer.rb
# frozen_string_literal: true

# This is application mailer class responsible for sending mail.
class ApplicationMailer < ActionMailer::Base
  default to: -> { ENV.fetch("DEFAULT_EMAIL") }
  layout "mailer"
end
