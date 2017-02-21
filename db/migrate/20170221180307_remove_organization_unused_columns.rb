class RemoveOrganizationUnusedColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :organizations, :initials
    remove_column :organizations, :dipres_id
    remove_column :organizations, :agreements_id
    remove_column :organizations, :address
  end
end
