class AddSuccessfulVisitToFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :feedbacks, :successful_visit, :boolean
    add_column :feedbacks, :unsuccessful_visit_explanation, :text
  end
end
