class AddIconUrlToTags < ActiveRecord::Migration
  def change
    add_column :tags, :icon_url, :string
  end
end
