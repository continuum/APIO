require "test_helper"
require_relative 'support/ui_test_helper'

class ShowServiceByOrganizationTest < Capybara::Rails::TestCase
  include UITestHelper
  include Warden::Test::Helpers
  after { Warden.test_reset! }

  test "Show User Organization Services last versions" do
    login_as(users(:pablito))
    visit organization_services_path(users(:pablito).roles.first.organization_id)
    assert_content 'Crear Servicio'
    assert page.all(:xpath, '//table/thead/tr')[0].text.include?('Fecha Nombre del servicio Revisión Autor Privado Estado')
    assert page.all(:xpath, '//table/tbody/tr').count == 1
    assert page.all(:xpath, '//table/tbody/tr')[0].text.include?('servicio_1')
  end

end
