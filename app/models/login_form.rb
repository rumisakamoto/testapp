# -*- encoding : utf-8 -*-
class LoginForm
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Validations

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value) rescue nil
    end
    @errors = ActiveModel::Errors.new(self)
  end

  attr_accessor :username, :password, :remember_me
  attr_reader :errors

  def persisted?
    false
  end

  def validate!
    @errors.add(:username, I18n.t('errors.messages.blank')) if username.blank?
    @errors.add(:password, I18n.t('errors.messages.blank')) if password.blank?
  end

  # The following methods are needed to be minimally implemented

  def read_attribute_for_validation(attr)
    send(attr)
  end

  def LoginForm.lookup_ancestors
    [self]
  end
end
