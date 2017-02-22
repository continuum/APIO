require './lib/role_service.rb'

class User < ApplicationRecord
  has_many :roles, dependent: :delete_all
  has_many :organizations, through: :roles
  has_many :service_versions
  has_many :schema_versions
  has_many :notifications
  has_many :agreement_versions

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :omniauthable, omniauth_providers: [:google_oauth2]

  GOB_DIGITAL_ID = ENV['MINSEGPRES_DIPRES_ID']

  URL = ENV['ROLE_SERVICE_URL']
  APP_ID = ENV['ROLE_APP_ID']

  #google_oauth2
  def self.from_omniauth(auth)
    info = auth.info
    credentials = auth.credentials
    user = User.where(:login_id => info.email).first_or_create!(login_id: info.email, login_provider: 'google_oauth2',
                                                                id_token: credentials.token, name: info.name,
                                                                can_create_schemas: false)
    if user.persisted?
      rol_name = 'Service Provider'
      org = Organization.where(name: user.login_id).first_or_create!(name: user.login_id)
      user.roles.where(organization: org, name: rol_name).first_or_create!(organization: org, name: rol_name)
      user.update!(id_token: credentials.token)
    end
    user
  end

  def is_service_admin?
    #gob_digital = Organization.where(dipres_id: GOB_DIGITAL_ID)
    #belongs_to_gobdigital = organizations.exists?(gob_digital)
    #is_service_provider = roles.where(organization: gob_digital).exists?(name: "Service Provider")
    #return false unless belongs_to_gobdigital && is_service_provider
    return true
  end

  def unread_notifications
    self.notifications.where(read: false).count
  end

  def unseen_notifications?
    self.notifications.exists?(seen: false)
  end

  def agreement_creation_organization(service)
    organizations_where_can_create_agreements(service).first
  end

  def can_create_agreements_to_many_organizations?(service)
    organizations_where_can_create_agreements(service).count > 1
  end

  def organizations_where_can_create_agreements(service)
    array = [service.organization_id]
    organizations.find_each do |org|
      array << org.id if org.has_agreement_for?(service)
    end
    organizations.where(['roles.name = ? AND roles.organization_id NOT IN (?)',"Create Agreement", array])
  end

  def organizations_with_agreement?(service)
    service.agreements.exists?(service_consumer_organization: self.organization_ids)
  end

  def organizations_have_agreements_for_all_orgs(service)
    return true if service.public
    organizations.find_each do |org|
      return false unless org.has_agreement_for?(service)
    end
    return true
  end

  def can_create_agreements?(org)
    roles.where(organization: org, name: "Create Agreement").exists?
  end

  def can_see_client_token_for_service?(service)
    !service.public && self.organizations.include?(service.organization)
  end

  def can_see_provider_secret_for_service?(service)
    return false if service.public # No secrets there
    return true if service.service_versions.where(version_number: 1).first.user == self # Original creator can see the secret
    # And validators and signers of agreements can also see secrets
    org = service.organization
    return (
      self.roles.where(organization: org, name: "Validate Agreement").exists? ||
      self.roles.where(organization: org, name: "Sign Agreement").exists?
    )
  end

  def can_see_credentials_for_agreement?(agreement)
    return false unless agreement.signed?
    return true if agreement.agreement_revisions.where(revision_number: 1).first.user == self  # The person who started the agreement can see the secret
    # And validators and signers of agreements can also see secrets
    org = agreement.consumer_organization
    return (
      self.roles.where(organization: org, name: "Validate Agreement").exists? ||
      self.roles.where(organization: org, name: "Sign Agreement").exists?
    )
  end

  def can_try_protected_service?(service)
    return true if self.organizations.include?(service.organization)
    service.agreements.where(service_consumer_organization: self.organization_ids).any?(&:signed?)
  end
end
