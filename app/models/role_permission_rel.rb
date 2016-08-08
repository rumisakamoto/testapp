# -*- encoding : utf-8 -*-
class RolePermissionRel < ActiveRecord::Base

  default_scope -> { where(deleted_at: nil) }

  belongs_to :role
  belongs_to :permission
end
