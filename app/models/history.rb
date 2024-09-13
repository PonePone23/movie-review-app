class History < ApplicationRecord
  belongs_to :user, class_name: 'User'
  belongs_to :movie, class_name: 'Movie'
end
