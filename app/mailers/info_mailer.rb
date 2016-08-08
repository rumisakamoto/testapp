# -*- encoding : utf-8 -*-
# システム利用状況周知メール送信バッチ
# lib/tasks/articles_info_mail_task で使用する
class InfoMailer < ActionMailer::Base
  default from: Settings.mail.from,
          to:   Settings.mail.info_to

  # 日次メール送信
  # ==== Args
  # _articles_ :: 昨日投稿された記事一覧
  def daily(articles)
    Rails.logger.info "Deliver daily articles info mail."
    @new_articles = articles
    mail subject: I18n.t('info_mail.daily.title', brand: I18n.t('brand_name'))
  end

  # 週次メール送信
  # ==== Args
  # _recommended_articles_ :: 先週推薦獲得数が多かった記事ベスト10
  # _favored_articles_ :: 先週お気に入り獲得数が多かった記事ベスト10
  def weekly(recommended_articles, favored_articles)
    Rails.logger.info "Deliver weekly articles' recommendations and favorites info mail."
    @recommended_articles = recommended_articles
    @favored_articles = favored_articles
    mail subject: I18n.t('info_mail.weekly.title', brand: I18n.t('brand_name'))
  end

  # 月次メール送信
  # ==== Args
  # _users_ :: 先月公開記事投稿数が多かったユーザベスト10
  def monthly(users)
    Rails.logger.info "Deliver monthly heavy users' info mail."
    @users = users
    mail subject: I18n.t('info_mail.monthly.title', brand: I18n.t('brand_name'))
  end
end
