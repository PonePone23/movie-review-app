# app/controllers/histories_controller.rb
class HistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_history, only: [:destroy]

  #def index
  #  @history_entries = current_user.histories.includes(:movie)
  #end

  def destroy
    @history.destroy
    redirect_to request.referrer, notice: 'Movie removed from history'
  end

  def delete_all
    current_user.histories.destroy_all
    redirect_to request.referrer, notice: 'All histories deleted'
  end

  private

  def set_history
    @history = current_user.histories.find(params[:id])
  end
end
