require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test '.from_omniauth sets Auth params to new user' do
    auth = Hashie::Mash.new(
      uid: 1111,
      info: {"email" => "perico1@continuum.cl", "name" => "Perico1"},
      credentials: {token: "ASDF"}
    )
    User.from_omniauth(auth)
    user = User.where(rut: "perico1@continuum.cl").first

    assert_equal "perico1@continuum.cl", user.rut
    assert_equal "Perico1", user.name
    assert_equal "1111", user.sub
    assert_equal "ASDF", user.id_token
    assert user.roles.empty?
    assert user.organizations.empty?
    assert !user.can_create_schemas
  end

  test ".unread_notifications return the number of unread_notifications of a user" do
    user = users(:pedro)
    assert_equal 0, user.unread_notifications
    user.notifications.create(subject: Service.first, message: "", email: "")
    user.notifications.create(subject: Service.first, message: "", email: "")
    assert_equal 2, user.unread_notifications
  end

  test ".unseen_notifications return if true if the user has unseen_notifications" do
    user = users(:pedro)
    assert_not user.unseen_notifications?
    user.notifications.create(subject: Service.first, message: "", email: "")
    user.notifications.create(subject: Service.first, message: "", email: "")
    assert user.unseen_notifications?
  end

  test ".can_create_agreements? return true if the user can create agreement for the organization" do
    user = users(:pedro)
    assert user.can_create_agreements?(organizations(:sii))
  end

  test ".can_create_agreements? return false if the user can't create agreement for the organization" do
    user = users(:pedro)
    assert_not user.can_create_agreements?(organizations(:segpres))
  end

end
