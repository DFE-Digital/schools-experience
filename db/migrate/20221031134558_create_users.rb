class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :sub

      t.timestamps
    end

    add_index :users, :sub, unique: true
  end
end
