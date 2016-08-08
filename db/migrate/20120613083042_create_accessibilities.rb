# -*- encoding : utf-8 -*-
class CreateAccessibilities < ActiveRecord::Migration
  def change
    create_table :accessibilities do |t|
      t.string   :name
      t.integer  :value,        null: false, default: 99
      t.datetime :deleted_at,                default: nil
      t.integer  :lock_version, null: false, default: 0

      t.timestamps
    end
    add_index :accessibilities, :value, unique: true
  end
end
