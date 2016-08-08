# -*- encoding : utf-8 -*-

#
# config/application.ymlのLDAP接続設定にしたがって、
# 指定されたユーザアカウントを認証します
#
module LdapAuthenticator

  FILTER_ATTR = "uid"
  EXTRACT_ATTR = ["userpassword", "mail"]
  RETURN_ATTR = :mail

  #
  # 与えられたユーザ名とパスワードをLDAPサーバに問い合わせて認証します
  # ==== Args
  # _uesrname_ :: ユーザ名
  # _password_ :: パスワード
  # ==== Return
  # Userオブジェクトを保存するにあたって必要なプロパティを保持するハッシュ
  # (認証失敗時はnil)
  #
  def self.authenticate(username, password)
    Rails.logger.info "ユーザ #{username} をLDAPサーバから検索します。"
    entry = search_entry(username)
    if password_valid?(password, entry)
      result = {
        username: username,
        password: password,
        password_confirmation: password,
        nickname: username,
        email: entry.first[RETURN_ATTR].first
      }
      Rails.logger.info "ユーザ #{username} のLDAP認証に成功しました。"
      #RETURN_ATTR.each do |attr|
        #result[attr] = entry.first[attr].first
      #end
      return result
    end
    return nil
  end

  #
  # 与えられたユーザ名をもつエントリをLDAPサーバに問い合わせます
  # ==== Args
  # _uesrname_ :: ユーザ名
  # ==== Return
  # LDAPエントリ
  #
  def self.search_entry(username)
    ldap = Net::LDAP.new(
      host: Settings.ldap.host,
      port: Settings.ldap.port.to_i,
      base: Settings.ldap.base,
      auth: {
        method: Settings.ldap.auth.method.to_sym,
        username: Settings.ldap.auth.username,
        password: Settings.ldap.auth.password
      }
    )
    filter = Net::LDAP::Filter.eq(FILTER_ATTR, username)
    entry = ldap.search(filter: filter, attributes: EXTRACT_ATTR, return_result: true)
    entry
  end

  #
  # LDAPエントリを使って与えられたパスワードを検証します
  # ==== Args
  # _password_ :: パスワード
  # _entry_ :: LDAPエントリ
  # ==== Return
  # 検証成功 -> true, 検証失敗 -> false
  #
  def self.password_valid?(password, entry)
    if entry.blank?
      Rails.logger.error "指定されたユーザ名がLDAPサーバに存在しません。"
      return false
    end
    # extract password from ldap search result
    pswd_hash = entry.first[EXTRACT_ATTR.first.to_sym].first.gsub(/#{Settings.ldap.password_prefix}/i, "")
    # validate password
    if password.crypt(pswd_hash).eql? pswd_hash
      Rails.logger.info "パスワードの認証に成功しました。"
      # return email if password is valid
      return true
    else
      Rails.logger.error "パスワードが不正です。"
      return false
    end
  rescue => e
    Rails.logger.error "LDAPパスワード認証中に予期せぬエラーが発生しました。"
    Rails.logger.error e
    return false
  end
end
