class CreateSchools < ActiveRecord::Migration[5.2]
  def change
    create_table :schools do |t|
      t.string :name, limit: 128, null: false
      t.st_point :coordinates, geographic: true
      t.timestamps
    end

    add_index :schools, :coordinates, using: :gist
    add_index :schools, :name
  end
end
