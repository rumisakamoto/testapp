# -*- encoding : utf-8 -*-
class Favorite < ActiveRecord::Base

  default_scope -> { where(deleted_at: nil).order('updated_at DESC') }
  scope :find_by_article_id_and_user_id, lambda {
    |article_id, user_id| where(article_id: article_id).where(user_id: user_id)
  }
  scope :find_by_user_id, lambda {
    |user_id| where(user_id: user_id)
  }
  scope :find_by_article_id, lambda {
    |article_id| where(article_id: article_id)
  }

  # for batch ranking
  # def self.favorites_count_on_last_week(article_id)
    # count_by_sql("select count(*) from favorites where article_id = #{article_id} and created_at between '#{1.week.ago.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")}' and '#{1.day.ago.end_of_day.strftime("%Y-%m-%d %H:%M:%S")}'")
  # end

  belongs_to :article, counter_cache: true
  belongs_to :user, counter_cache: true

  def self.add(article_id, user_id)
    favorite = Favorite.new
    favorite.article_id = article_id
    favorite.user_id = user_id
    favorite.save!
    get_favorite_count(article_id)
  end

  def self.delete(article_id, user_id)
    favorite = Favorite.find_by_article_id_and_user_id(article_id, user_id).first
    favorite.destroy if favorite
    get_favorite_count(article_id)
  end

  private

  def self.get_favorite_count(article_id)
    Article.find(article_id).favorites_count
  end

end
