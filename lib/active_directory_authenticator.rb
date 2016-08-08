# -*- encoding : utf-8 -*-

#
# config/application.ymlのActivedirectory接続設定にしたがって、
# 指定されたユーザアカウントを認証します
#
module ActiveDirectoryAuthenticator

  FILTER_ATTR = "sAMAccountName"
  EXTRACT_ATTR = ["displayname"]
  RETURN_ATTR = :displayname

  #
  # 与えられたユーザ名とパスワードをActivedirectoryサーバに問い合わせて認証します
  # Activedirectoryサーバに与えられたユーザ名とパスワードで接続し、
  # 接続が成功するかどうかによって認証します
  # ==== Args
  # _uesrname_ :: ユーザ名
  # _password_ :: パスワード
  # ==== Return
  # Userオブジェクトを保存するにあたって必要なプロパティを保持するハッシュ
  # (認証失敗時はnil)
  #
  def self.authenticate(username, password)
    Rails.logger.info "ユーザ #{username} をActivedirectoryサーバから検索します。"
    entry = search_entry(username, password)
    unless entry.blank?
      result = {
        username: username,
        password: password,
        password_confirmation: password,
        email: "#{username}@example.com",
        nickname: entry.first[RETURN_ATTR].first
      }
      Rails.logger.info "ユーザ #{username} のActivedirectory認証に成功しました。"
      return result
    end
    return nil
  end

  #
  # 与えられたユーザ名とパスワードでActivedirectoryエントリを検索します
  # ==== Args
  # _uesrname_ :: ユーザ名
  # _password_ :: パスワード
  # ==== Return
  # Activedirectoryエントリ
  # (認証失敗時は空の配列になる)
  #
  def self.search_entry(username, password)
    ldap = Net::LDAP.new(
      host: Settings.activedirectory.host,
      port: Settings.activedirectory.port.to_i,
      base: Settings.activedirectory.base,
      auth: {
        method: Settings.activedirectory.auth.method.to_sym,
        username: "#{username}@#{Settings.activedirectory.host}",
        password: "#{password}"
      }
    )
    filter = Net::LDAP::Filter.eq(FILTER_ATTR, username)
    ldap.search(filter: filter, attributes: EXTRACT_ATTR, return_result: true)
  end
end
