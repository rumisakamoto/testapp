# -*- encoding : utf-8 -*-
class Settings < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env

  def self.ldap_auth?
    self.authentication.setting == self.authentication.methods.ldap
  end

  def self.app_auth?
    self.authentication.setting == self.authentication.methods.app
  end

  def self.ad_auth?
    self.authentication.setting == self.authentication.methods.ad
  end
end
