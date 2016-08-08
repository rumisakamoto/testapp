# -*- encoding : utf-8 -*-
class Accessibility < ActiveRecord::Base

  INACTIVE  = -1
  ANONYMOUS =  0
  MEMBER    =  1
  LEADER    =  2
  MANAGER   =  3
  ADMIN     = 98
  PRIVATE   = 99

  default_scope ->(){ where(deleted_at: nil) }
  scope :selectables, lambda { |user|
    user_accessibility = Accessibility::ANONYMOUS
    unless user.blank?
      user_accessibility = user.role.accessibility.value
    end
    if user_accessibility < Accessibility::ANONYMOUS
      return []
    end
    where('value >= 0 AND (value <= ? OR value = ?)', user_accessibility, Accessibility::PRIVATE)
  }
  scope :anonymous, -> { where(value: Accessibility::ANONYMOUS) }
  scope :admin, -> { where(value: Accessibility::ADMIN) }
  scope :privates, -> { where(value: Accessibility::PRIVATE) }
  scope :inactive, -> { where(value: Accessibility::INACTIVE) }

  validates :value, presence: true, numericality: { greater_than_or_equal_to: Accessibility::INACTIVE, less_than_or_equal_to: Accessibility::PRIVATE }, uniqueness: true

  def self.selections(user)
    accessbilities = {}.with_indifferent_access
    user_selectables = Accessibility.selectables(user).reload
    user_selectables.each do |accessibility|
      key = accessibility.value
      value = I18n.t(accessibility.name)
      accessbilities[key] = value
    end
    accessbilities
  end

  def admin?
    value == ADMIN
  end

  def inactive?
    value == INACTIVE
  end
end
