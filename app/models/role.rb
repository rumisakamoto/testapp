# -*- encoding : utf-8 -*-
class Role < ActiveRecord::Base

  default_scope -> { where(deleted_at: nil) }
  scope :find_by_accessbility_id, lambda { |accessibility_id| where(accessibility_id: accessibility_id) }
  scope :find_by_name, lambda { |name| where(name: name) }

  has_many :users
  has_many :role_permission_rels
  has_many :permissions, through: :role_permission_rels
  belongs_to :accessibility

  validates :name, presence: true

  def self.selections
    roles = {}.with_indifferent_access
    Role.all.each do |role|
      key = role.id
      value = I18n.t(role.name)
      roles[key] = value
    end
    roles
  end

  def self.get_name(role_id)
    role = Role.find(role_id)
    if role
      return I18n.t(role.name)
    end
    ""
  end
end
