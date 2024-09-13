# app/models/activity.rb
# frozen_string_literal: true

# This class represents actvities of user
class Activity < ApplicationRecord
  # Associations
  belongs_to :user
end
