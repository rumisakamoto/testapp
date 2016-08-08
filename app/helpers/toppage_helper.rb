# -*- encoding : utf-8 -*-
module ToppageHelper

  # トップページの「新規登録」リンク文字列を返します。
  # 「新規登録」リンクが出力される条件は以下です。
  #
  # - ログイン済みであること
  # - 認証モードが「application」であること
  # - ユーザのロールが管理者であること
  # ==== Args
  # ==== Return
  # 条件を満たす場合は「新規登録」リンク文字列, そうでない場合は何も返さない
  def link_to_signup
    if current_user && Settings.app_auth? && current_user.admin?
      return link_to t('signup'), signup_path
    end
  end

  def welcome_message
    message = t('.welcome', brand: t('brand_name'))
    if Settings.ldap_auth?
      message << t('.welcome_ldap')
    elsif Settings.ad_auth?
      message << t('.welcome_ad')
    else
      message << t('.welcome_app')
    end
    return simple_format(message)
  end
end
