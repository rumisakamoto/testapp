# -*- encoding : utf-8 -*-

class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string   :name,             null: false
      t.integer  :accessibility_id, null: false
      t.datetime :deleted_at,                default: nil

      t.integer  :lock_version,     null: false, default: 0

      t.timestamps
    end
  end

end
