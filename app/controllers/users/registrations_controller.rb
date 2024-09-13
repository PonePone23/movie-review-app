class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters
  
  def create
    super do |resource|
      if resource.errors.any?
        flash[:alert] = "Please fix the errors below."
      elsif User.where(admin: true).count == 0 && /@admin\.com\z/.match?(resource.email)
        resource.admin = true
        resource.save
      end
    end
  end
  
  def update
    super
    current_user.activities.create(action: 'profile_updated')
  end

  def destroy
    @user = current_user
    Notification.where(actor_id: @user.id).destroy_all
    if current_user.valid_password?(params[:user][:current_password])
      super
    else
      redirect_to edit_user_registration_path, alert: 'Incorrect password. Account deletion failed.'
    end
  end
  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :admin])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name,:image])
  end
end
