class AddUrnToFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :feedbacks, :urn, :integer
  end
end
