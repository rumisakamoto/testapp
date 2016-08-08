# -*- encoding : utf-8 -*-
require 'migration_helper.rb'

class CreateArticleRecommendations < ActiveRecord::Migration
  include MigrationHelper
  def change
    create_table :article_recommendations do |t|
      t.integer  :article_id,   null: false
      t.integer  :user_id,      null: false
      t.datetime :deleted_at,   default: nil
      t.integer  :lock_version, null: false, default: 0

      t.timestamps
    end
    add_index :article_recommendations, [:article_id, :user_id], :unique => true
  end
end
