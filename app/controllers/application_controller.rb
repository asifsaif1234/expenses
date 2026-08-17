class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_user
  helper_method :user_signed_in?

  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :avatar])
  end

  def turbo_request?
    request.headers["Turbo-Frame"].present? || 
    request.headers["Accept"]&.include?("text/vnd.turbo-stream.html")
  end

  def respond_with_turbo(resource, action, options = {})
    if resource.persisted?
      flash.now[:notice] = options[:notice] || "#{resource.class.name} was successfully created."
      render turbo_stream: [
        turbo_stream.prepend("resources_list", partial: resource),
        turbo_stream.replace("flash_messages", partial: "shared/flash"),
        turbo_stream.replace("#{resource.class.name.underscore}_form", 
                            partial: "form", 
                            locals: { resource.class.name.underscore.to_sym => resource.class.new })
      ]
    else
      flash.now[:alert] = options[:alert] || "Failed to create #{resource.class.name}."
      render turbo_stream: [
        turbo_stream.replace("#{resource.class.name.underscore}_form", 
                            partial: "form", 
                            locals: { resource.class.name.underscore.to_sym => resource }),
        turbo_stream.replace("flash_messages", partial: "shared/flash")
      ], status: :unprocessable_entity
    end
  end
end
