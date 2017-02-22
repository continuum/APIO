class RemoveRoleEmail < ActiveRecord::Migration[5.0]
  def change
    remove_column :roles, :email
  end
end
