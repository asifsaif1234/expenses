# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
  end

  def create
    # Let Devise handle authentication
    super do |resource|
      # Custom logic after successful sign in
      if resource.persisted?
        flash[:notice] = "Welcome back, #{resource.full_name || resource.email}!"
        redirect_to expenses_path and return
      end
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
    expenses_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
