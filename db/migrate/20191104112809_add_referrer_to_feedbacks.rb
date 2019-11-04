class AddReferrerToFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :feedbacks, :referrer, :string, null: true
  end
end
