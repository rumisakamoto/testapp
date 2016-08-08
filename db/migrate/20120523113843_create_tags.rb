# -*- encoding : utf-8 -*-
require 'migration_helper.rb'

class CreateTags < ActiveRecord::Migration
	include MigrationHelper
  def change
    create_table :tags do |t|
      t.string   :name,                   null: false
      t.integer  :user_id,                null: false
      t.datetime :deleted_at,             default: nil
      t.integer  :lock_version,           null: false, default: 0
      t.integer  :article_tag_rels_count, null: false, default: 0
      t.timestamps
    end
  end
end
