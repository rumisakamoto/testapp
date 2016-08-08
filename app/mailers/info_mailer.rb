# -*- encoding : utf-8 -*-
# $B%7%9%F%`MxMQ>u67<~CN%a!<%kAw?.%P%C%A(B
# lib/tasks/articles_info_mail_task $B$G;HMQ$9$k(B
class InfoMailer < ActionMailer::Base
  default from: Settings.mail.from,
          to:   Settings.mail.info_to

  # $BF|<!%a!<%kAw?.(B
  # ==== Args
  # _articles_ :: $B:rF|Ej9F$5$l$?5-;v0lMw(B
  def daily(articles)
    Rails.logger.info "Deliver daily articles info mail."
    @new_articles = articles
    mail subject: I18n.t('info_mail.daily.title', brand: I18n.t('brand_name'))
  end

  # $B=5<!%a!<%kAw?.(B
  # ==== Args
  # _recommended_articles_ :: $B@h=5?dA&3MF@?t$,B?$+$C$?5-;v%Y%9%H(B10
  # _favored_articles_ :: $B@h=5$*5$$KF~$j3MF@?t$,B?$+$C$?5-;v%Y%9%H(B10
  def weekly(recommended_articles, favored_articles)
    Rails.logger.info "Deliver weekly articles' recommendations and favorites info mail."
    @recommended_articles = recommended_articles
    @favored_articles = favored_articles
    mail subject: I18n.t('info_mail.weekly.title', brand: I18n.t('brand_name'))
  end

  # $B7n<!%a!<%kAw?.(B
  # ==== Args
  # _users_ :: $B@h7n8x3+5-;vEj9F?t$,B?$+$C$?%f!<%6%Y%9%H(B10
  def monthly(users)
    Rails.logger.info "Deliver monthly heavy users' info mail."
    @users = users
    mail subject: I18n.t('info_mail.monthly.title', brand: I18n.t('brand_name'))
  end
end
