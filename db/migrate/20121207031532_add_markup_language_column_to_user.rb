class AddMarkupLanguageColumnToUser < ActiveRecord::Migration
  def change
      add_column :users, :markup_lang, :integer
  end
end
