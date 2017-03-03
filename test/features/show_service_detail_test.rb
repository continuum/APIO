require "test_helper"
require_relative 'support/ui_test_helper'

class ShowServiceDetailTest < Capybara::Rails::TestCase
  include UITestHelper
  include Warden::Test::Helpers
  after { Warden.test_reset! }

  before do
    @service_v = Service.create!(
      name: "PetsServiceName",
      organization: organizations(:sii),
      public: true,
      spec_file: File.open(Rails.root / "test/files/sample-services/petsfull.yaml")
    ).create_first_version(users(:pedro))
  end

  test "Show service" do
    visit organization_service_service_version_path(
      @service_v.organization, @service_v.service, @service_v
    )
    assert_content "PetsServiceName"
    assert_link "Ver OAS"
    assert_button "Generar código fuente"
    assert_content "http://petstore.swagger.io/v2"
    click_button "Ver Descripción"
    assert_content "This is a sample server Petstore server."
    assert_content "For this sample, you can use the api key special-key to test the authorization filters"
  end
end
