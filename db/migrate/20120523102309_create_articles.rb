# -*- encoding : utf-8 -*-
require 'migration_helper.rb'

class CreateArticles < ActiveRecord::Migration
  include MigrationHelper
  def change
    create_table :articles do |t|
      t.string    :title,                 null: false
      t.text      :content,               null: false
      t.datetime  :deleted_at,            default: nil

      t.integer   :feedbacks_count,       null: false, default: 0
      t.integer   :favorites_count,       null: false, default: 0
      t.integer   :article_recommendations_count,
                                          null: false, default: 0
      t.integer   :article_tag_rels_count,
                                          null: false, default: 0

      t.integer   :user_id,               null: false
      t.integer   :category_id,           null: false, default: 0
      t.integer   :notation_type,         null: false, default: 0
      t.integer   :publicity_level,       null: false, default: 0
      t.integer   :article_type,          null: false, default: 0

      t.integer   :lock_version,          null: false, default: 0

      t.timestamps
    end
  end
end
