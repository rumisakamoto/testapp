# -*- encoding : utf-8 -*-
class Permission < ActiveRecord::Base

  default_scope -> { where(deleted_at: nil) }

  has_many :role_permission_rels
  has_many :roles, through: :role_permission_rels

  validates :action_name, presence: true
  validates :class_name, presence: true
end
