# -*- encoding : utf-8 -*-
require 'migration_helper.rb'

class CreateArticleTagRels < ActiveRecord::Migration
	include MigrationHelper
  def change
    create_table :article_tag_rels do |t|
      t.integer  :article_id,   null: false
      t.integer  :tag_id,       null: false
      t.datetime :deleted_at,   default: nil
      t.integer  :lock_version, null: false, default: 0

      t.timestamps
    end
  end
end
