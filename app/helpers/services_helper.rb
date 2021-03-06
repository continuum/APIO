module ServicesHelper

  def css_class_for_status(status)
    {
      'outdated' => 'static',
      'retired' => 'default',
      'proposed' => 'primary',
      'current' => 'success',
      'retracted' => 'warning',
      'rejected' => 'danger'
    }[status] + ' btn-status' || ''
  end

  def organization_services
    if current_user.present?
      org = current_user.organizations.first
      organization_services_path(org)
    else
      services_path
    end
  end
end
