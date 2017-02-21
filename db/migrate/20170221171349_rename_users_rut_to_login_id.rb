class RenameUsersRutToLoginId < ActiveRecord::Migration[5.0]
  def change

    rename_column :users, :rut, :login_id
    rename_column :users, :sub, :login_provider

  end
end
