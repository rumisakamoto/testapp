# -*- encoding : utf-8 -*-
require 'migration_helper.rb'
class AddRoleIdToUsers < ActiveRecord::Migration
  include MigrationHelper
  def change
    remove_column :users, :authority_level
    add_column    :users, :role_id, :integer
  end
end
