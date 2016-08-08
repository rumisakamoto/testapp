# -*- encoding : utf-8 -*-
class AddLastUpdatedAtToArticlesAndFeedbacks < ActiveRecord::Migration
  def change
    add_column :articles,  :last_updated_at, :datetime
    add_column :feedbacks, :last_updated_at, :datetime
  end
end
