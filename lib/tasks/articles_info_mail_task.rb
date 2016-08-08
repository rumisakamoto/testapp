# -*- encoding : utf-8 -*-
#
# batch processes to mail articles information
#
class Tasks::ArticlesInfoMailTask
  def self.execute
    InfoMailer.daily(Article.created_on_yesterday).deliver
    InfoMailer.weekly(Article.recommended_on_last_week, Article.favored_on_last_week).deliver if Date.today.wday == 1
    InfoMailer.monthly(User.heavy_users_on_last_month).deliver if Date.today.day == 1
  end
end
