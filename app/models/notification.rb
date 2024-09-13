# app/models/notification.rb
# frozen_string_literal: true

# This class represents Notifications for users.
class Notification < ApplicationRecord
  # Associations
  belongs_to :recipient, class_name: 'User'
  belongs_to :actor, class_name: 'User'
  belongs_to :notifiable, polymorphic: true
end
