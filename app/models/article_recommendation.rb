# -*- encoding : utf-8 -*-
class ArticleRecommendation < ActiveRecord::Base

  default_scope -> { where(deleted_at: nil) }
  scope :find_by_article_id_and_user_id, lambda {
    |article_id, user_id| where(article_id: article_id).where(user_id: user_id)
  }
  scope :find_by_article_id, lambda {
    |article_id| where(article_id: article_id)
  }

  # for batch ranking
  # def self.recommendations_count_on_last_week(article_id)
    # count_by_sql("select count(*) from article_recommendations where article_id = #{article_id} and created_at between '#{1.week.ago.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")}' and '#{1.day.ago.end_of_day.strftime("%Y-%m-%d %H:%M:%S")}'")
  # end

  belongs_to :article, counter_cache: true
  belongs_to :user, counter_cache: true

  # deletes specified entity
  # ==== Args
  # _article__id_ :: target article
  # _user_id_ :: current user id
  # ==== Return
  # total recommendations count of target
  def self.delete(article_id, user_id)
    recommend = ArticleRecommendation.find_by_article_id_and_user_id(article_id, user_id).first
    recommend.destroy if recommend
    get_recommendations_count(article_id)
  end

  # inserts new entity
  # ==== Args
  # _article_id_ :: target article id
  # _user_id_ :: current user id
  # ==== Return
  # total recommendations count of target
  def self.add(article_id, user_id)
    ArticleRecommendation.where(article_id: article_id, user_id: user_id).first_or_create!
    get_recommendations_count(article_id)
  end

  private

  # gets total recommendations count for specified article
  # ==== Args
  # _article_id_ :: target article id
  # ==== Return
  # total recommendations count of target
  def self.get_recommendations_count(article_id)
    article = Article.find(article_id)
    article.article_recommendations_count
  rescue
    return 0
  end

end
