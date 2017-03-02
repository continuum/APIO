require "test_helper"
require_relative 'support/ui_test_helper'

class FilterOrganizationServicesTest < Capybara::Rails::TestCase
  include UITestHelper
  include Warden::Test::Helpers
  after { Warden.test_reset! }

  before do
    @service_v = Service.create!(
      name: "PetsService",
      organization: organizations(:sii),
      public: true,
      spec_file: File.open(Rails.root / "test/files/sample-services/petsfull.yaml")
    ).create_first_version(users(:pedro))
    @another_service_v = Service.create!(
      name: "EchoService",
      organization: organizations(:sii),
      public: true,
      spec_file: File.open(Rails.root / "test/files/sample-services/echo.yaml")
    ).create_first_version(users(:pedro))
    @another_service_v = Service.create!(
      name: "EchoServiceWithManyParams",
      organization: organizations(:sii),
      public: true,
      spec_file: File.open(Rails.root / "test/files/sample-services/echo-many-params.yaml")
    ).create_first_version(users(:pedro))
  end

  test "Filter/Search on the table with services of my organization" do
    login_as users(:pedro)
    visit organization_services_path(users(:pedro).roles.first.organization_id)
    assert_content "PetsService"
    assert_content "EchoService"
    assert_content "EchoServiceWithManyParams"
    find('[placeholder="Ingresa nombre de Servicio"]').set('PETS')
    assert_content "PetsService"
    assert_no_content "EchoService"
    assert_no_content "EchoServiceWithManyParams"
    find('[placeholder="Ingresa nombre de Servicio"]').set('echo')
    assert_no_content "PetsService"
    assert_content "EchoService"
    assert_content "EchoServiceWithManyParams"
    find('[placeholder="Ingresa nombre de Servicio"]').set(' ')
    assert_content "PetsService"
    assert_content "EchoService"
    assert_content "EchoServiceWithManyParams"
  end
end
