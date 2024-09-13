# app/controllers/discussions_controller.rb
# frozen_string_literal: true

# This controller manages discussuions.
class DiscussionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_discussion, only: [:show, :edit, :update, :destroy]

  # Method for showing all discussions in index page
  def index
    current_user.activities.create(action:"Browsed Discussion Page")
    @discussions = Discussion.all
  end

  # Method for showing each discussion with related reactions and replies
  def show
    @discussion = Discussion.find(params[:id])
    @replies = @discussion.replies.order(created_at: :desc).page(params[:page]).per(5)
    @reactions = @discussion.reactions
    current_user.activities.create(action:"Viewed Discussion '#{@discussion.content}'")
  end

  # Method for creating new discussion
  def new
    @discussion = Discussion.new
  end

  # Method for creating new discussion
  def create
    @discussion = current_user.discussions.build(discussion_params)
    if @discussion.save
      redirect_to discussions_url, notice: 'Discussion was successfully created.'
      current_user.activities.create(action:"Created Discussion #{@discussion.content}")
    else
      render :new
    end
  end

  # Method for editing the existing discussion
  def edit
  end

  # Method for updating the existing discussion
  def update
    if @discussion.update(discussion_params)
      redirect_to @discussion, notice: 'Discussion was successfully updated.'
    else
      render :edit
    end
  end

  # Method for destroying the exisitng discussion
  def destroy
    @discussion.destroy
    redirect_to discussions_url, notice: 'Discussion was successfully destroyed.'
    current_user.activities.create(action:"Destroyed Discussion")
  end

  private

  def set_discussion
    @discussion = Discussion.find(params[:id])
  end

  def discussion_params
    params.require(:discussion).permit(:content)
  end
end
