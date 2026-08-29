# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    # Try to authenticate the user
    user = User.find_by(email: params[:user][:email])

    if user && user.valid_password?(params[:user][:password])
      # Sign in the user
      sign_in(:user, user)

      # Set flash message
      flash[:notice] = "Welcome back, #{user.full_name || user.email}!"

      # Redirect to dashboard
      redirect_to dashboard_path and return
    else
      # Invalid credentials
      flash[:alert] = "Invalid email or password. Please try again."

      # Re-render sign in form
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super do
      redirect_to root_path and return
    end
  end

  protected

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
