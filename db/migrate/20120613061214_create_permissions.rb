# -*- encoding : utf-8 -*-

class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string   :action_name,  null: false
      t.string   :class_name,   null: false
      t.string   :optional_condition,        default: nil
      t.datetime :deleted_at,                default: nil

      t.integer  :lock_version, null: false, default: 0

      t.timestamps
    end
  end

end
