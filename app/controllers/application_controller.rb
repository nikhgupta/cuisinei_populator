class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # after_action :verify_authorized, except:  :index
  # after_action :verify_policy_scoped, only: :index
  before_action :redirect_namespace_if_required

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def after_sign_in_path_for(resource)
    resource.admin? ? admin_dashboard_path : dashboard_path
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    path = current_user.admin? ? admin_dashboard_path : dashboard_path
    redirect_to(request.referrer || path)
  end

  # FIXME: This is kinda effective, but hackish.
  def redirect_namespace_if_required
    return if request.path == destroy_user_session_path
    return if request.path == new_user_session_path
    redirect_to(new_user_session_path) and return unless current_user

    spaces = ActiveAdmin.application.namespaces.names - [:root]
    ns = spaces.detect{|s| request.path =~ /^\/#{s}/ }
    return if (ns.blank? && !current_user.admin?) || (ns && current_user.send("#{ns}?"))

    flash[:alert] = "You seem to have wandered off to some strange world."
    redirect_to(current_user.admin? ? admin_dashboard_path : dashboard_path)
  end
end
