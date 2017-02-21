class RemoveUsersLoginProviderUniqueConstraint < ActiveRecord::Migration[5.0]
  def change
    remove_index :users, :login_provider
  end
end
