# -*- encoding : utf-8 -*-
require 'migration_helper.rb'

class CreateFeedbacks < ActiveRecord::Migration
  include MigrationHelper
  def change

    create_table :feedbacks do |t|
      t.integer  :article_id,                     null: false
      t.integer  :user_id,                        null: false
      t.integer  :feedback_type,                           null: false, default: 0
      t.integer  :notation_type,                  null: false, default: 0
      t.integer  :feedback_recommendations_count, default: 0
      t.text     :content,                        null: false
      t.datetime :deleted_at,                     default: nil
      t.integer  :lock_version,                   null: false, default: 0

      t.timestamps
    end
  end
end
