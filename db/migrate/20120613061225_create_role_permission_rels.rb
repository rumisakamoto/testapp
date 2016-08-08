# -*- encoding : utf-8 -*-
require 'migration_helper.rb'
class CreateRolePermissionRels < ActiveRecord::Migration
  include MigrationHelper
  def change
    create_table :role_permission_rels do |t|
      t.integer  :role_id,       null: false
      t.integer  :permission_id, null: false
      t.datetime :deleted_at,                 default: nil

      t.integer  :lock_version,  null: false, default: 0

      t.timestamps
    end
    add_index :role_permission_rels, [:role_id, :permission_id], unique: true
  end

end
