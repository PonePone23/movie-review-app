# app/controllers/reactions_controller.rb
# frozen_string_literal: true

# This controller manages reactions related to discussion of user.
class ReactionsController < ApplicationController
  before_action :find_discussion

  # Method for creating new reaction
  def create
    @discussion.reactions.where(user_id: current_user.id).destroy_all
    @reaction = @discussion.reactions.build(reaction_params)
    @reaction.user_id = current_user.id

    respond_to do |format|
      if @reaction.save
        format.html { redirect_to @discussion }
        format.js
      else
        format.html { redirect_to @discussion, alert: 'Failed to create reaction.' }
        format.js { render 'create_failure.js.erb' }
      end
    end
  end

  private

  def find_discussion
    @discussion = Discussion.find(params[:discussion_id])
  end

  def reaction_params
    params.require(:reaction).permit(:reaction_type)
  end
end
