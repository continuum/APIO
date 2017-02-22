class HomeController < ApplicationController
  def root
    redirect_to services_path
  end

  def index
    @organization_services = Service.publics
  end

  def search
    @text_search = params[:text_search]
    organization = Organization.where(name: @text_search).first
    if organization.blank?
      @services = Service.search(params[:text_search])
    else
      @services = organization.services
    end
  end

  def pending_approval
    return unless user_signed_in?
    if current_user.is_service_admin?
      @pending_services_version = ServiceVersion.proposed
    else
      redirect_to root_path, notice: t(:not_enough_permissions)
    end
  end
end
