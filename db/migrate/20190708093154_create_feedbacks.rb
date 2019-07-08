class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :feedbacks do |t|
      t.string :type, null: false
      t.integer :reason_for_using_service, null: false
      t.text :reason_for_using_service_explanation
      t.integer :rating, null: false
      t.text :improvements

      t.timestamps
    end
  end
end
