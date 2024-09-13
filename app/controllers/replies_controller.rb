# app/controllers/replies_controller.rb
# frozen_string_literal: true

# This controller manages replies related to discussion.
class RepliesController < ApplicationController
  # Method for creating new reply
  def create
    @discussion = Discussion.find(params[:discussion_id])
    @reply = @discussion.replies.build(reply_params)
    @reply.user_id = current_user.id
    if @reply.save
      redirect_to @discussion, notice: 'Reply was successfully created.'
      current_user.activities.create(action:"Added Reply '#{@reply.content}' under discussion '#{@discussion.content}'.")
    else
      redirect_to @discussion, alert: 'Failed to create reply.'
    end
  end

  # Method for deleting existing reply
  def destroy
    @discussion = Discussion.find(params[:discussion_id])
    @reply = Reply.find_by(id: params[:id])
    @reply.destroy
    current_user.activities.create(action:"Deleted Reply under diuscussion '#{@discussion.content}'.")
    redirect_to discussion_path(@reply.discussion_id), notice: 'Reply was successfully destroyed.'
  end

  private

  def reply_params
    params.require(:reply).permit(:content)
  end
end
