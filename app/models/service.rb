class Service < ApplicationRecord
  belongs_to :organization
  has_many :service_versions

  validates :name, uniqueness: true

  after_create :create_first_version

  attr_accessor :spec_file

  def to_param
    name
  end

  def create_first_version
    service_versions.create(spec_file: self.spec_file)
  end

  def last_version_number
    service_versions.maximum(:version_number) || 0
  end
end