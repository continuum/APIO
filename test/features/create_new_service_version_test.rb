require "test_helper"
require_relative 'support/ui_test_helper'

class CreateNewServiceVersionTest < Capybara::Rails::TestCase
  include UITestHelper
  include Warden::Test::Helpers
  after { Warden.test_reset! }

  setup do
    login_as users(:pablito), scope: :user
    visit services_path
    visit organization_services_path(users(:pablito).roles.first.organization_id)
    page.find(:xpath, '//table/tbody/tr[1]').click
    assert_content ('servicio_1')
    click_link('Nueva Revisión')
    assert_content page, "Seleccionar Archivo"
    page.execute_script('$("input[type=file]").show()')
  end

  test "attempt to create a service without an attached file" do
    click_button "Subir Nueva Revisión"
    assert_content page, "No se pudo crear la revisión"
  end

  test "create a valid service" do
    attach_file 'service_version_spec_file', Rails.root.join(
      'test', 'files', 'sample-services', 'petsfull.yaml')
    click_button "Subir Nueva Revisión"
    assert_content page, "Nueva revisión creada correctamente"
  end
end
