# -*- encoding : utf-8 -*-
class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string       :name,           null: false
      t.integer      :articles_count, default: 0
      t.datetime     :deleted_at,     default: nil
      t.integer      :lock_version,   null: false, default: 0

      t.timestamps
    end
  end
end
