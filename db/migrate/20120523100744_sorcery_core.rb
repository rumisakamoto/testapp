# -*- encoding : utf-8 -*-
class SorceryCore < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :username,         null: false
      t.string   :email,            null: false
	  t.string   :nickname,         null: false
      t.string   :crypted_password, null: false
	  t.string   :icon_url,         default: nil
      t.string   :salt,             default: nil
	  t.integer  :authority_level,  null:false,   default: 0
      t.integer  :articles_count,    default: 0
      t.integer  :feedbacks_count,  default: 0
      t.integer  :favorites_count,  default: 0
      t.integer  :article_recommendations_count,  default: 0
      t.integer  :feedback_recommendations_count, default: 0
	  t.integer  :lock_version,     null: false,  default: 0
	  t.datetime :deleted_at,       default: nil
      t.timestamps
    end
    add_index    :users, :username, unique: true, name: 'username'
  end

  def self.down
	  remove_index :users, name: 'username'
    drop_table :users
  end
end

