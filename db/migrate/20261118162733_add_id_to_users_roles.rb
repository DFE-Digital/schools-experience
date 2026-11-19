class AddIdToUsersRoles < ActiveRecord::Migration[8.1]
  def change
    add_column :users_roles, :id, :bigserial, primary_key: true
  end
end
