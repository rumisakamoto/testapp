# -*- encoding : utf-8 -*-
require 'content_formatter'

class Article < ActiveRecord::Base
  include ContentFormatter

  PER_PAGE = 5

  module Tab
    module Suffix
      TAB = "_tab"
      TAB_CONTENT = "_tabcontent"
    end
    module Type
      ALL = "all_articles"
      MY = "my_articles"
      PRIVATES = "privates"
      FAVORITES = "favorites"
      RECENTLY_FEEDBACKED = "recently_feedbacked"
      RECENTLY_RECOMMENDED = "recently_recommended"
    end
  end
  module List
    module Type
      FEEDBACKS_RECOMMENDED = "feedbacks_recommended"
      RECOMMEND = "recommend"
      RECOMMENDED = "recommened"
      FAVORITES = "favorite"
      USER = "user"
      SEARCH = "search"
      TAG = "tag"
    end
  end


  default_scope -> { where(deleted_at: nil) }

  scope :order_by_last_updated_at_desc, -> { order("articles.last_updated_at DESC") }
  # get articles which are accessble by specified user
  # if user is not specified, articles which are accessble by anonymous users are loaded
  scope :accessibles, lambda { |user|
    find_private_articles_query = ""
    accessibility = Accessibility::ANONYMOUS
    if User.valid?(user)
      find_private_articles_query = "OR (articles.publicity_level = #{Accessibility::PRIVATE} AND articles.user_id = #{user.id})"
      accessibility = user.role.accessibility.value
    end
    where("articles.publicity_level <= ? #{find_private_articles_query}", accessibility)
  }
  scope :find_by_user_id, lambda { |user_id| where(user_id: user_id) }
  scope :find_by_category_id, lambda { |category_id| where(category_id: category_id) }
  scope :most_recommended, lambda { |user| accessibles(user).recommended.order("article_recommendations_count DESC") }
  scope :recommended, -> { where("article_recommendations_count > 0") }
  scope :order_by_recommendations_count_desc, -> { order("article_recommendations_count DESC") }
  scope :most_favorited, lambda { |user| accessibles(user).favored.order("favorites_count DESC") }
  scope :favored, -> { where("favorites_count > 0") }
  scope :order_by_favorites_count_desc, -> { order("favorites_count DESC") }
  scope :privates, lambda { |user|
    if User.valid?(user)
      where(user_id: user.id).where(publicity_level: Accessibility::PRIVATE)
    else
      []
    end
  }
  scope :publics, -> { where('publicity_level <> ?', Accessibility::PRIVATE) }
  # gets articles which have specified user's feedbacks recommened by other users
  scope :feedbacks_recommended, lambda { |user|
    joins(:feedbacks).group('articles.id').where('feedbacks.user_id = ?', user.id).where('feedbacks.feedback_recommendations_count > 0').order('feedbacks.feedback_recommendations_count DESC')
  }
  scope :recently_feedbacked, lambda { |user| joins(:feedbacks).group('articles.id').accessibles(user).order('feedbacks.last_updated_at DESC') }
  scope :recently_recommended, lambda { |user| joins(:article_recommendations).group('articles.id').accessibles(user).order('article_recommendations.created_at DESC') }
  scope :recently_created, lambda { |user, datetime| publics.where('created_at > ?', datetime).order_by_last_updated_at_desc }

  # for batch ranking
  scope :created_on_yesterday, -> {
    where('publicity_level <> ? AND created_at BETWEEN ? AND ?', Accessibility::PRIVATE, 1.day.ago.beginning_of_day, 1.day.ago.end_of_day)
  }
  scope :favored_on_last_week, -> {
    joins("inner join (select article_id, count(*) as count_of_last_week from favorites f where f.created_at BETWEEN '#{1.week.ago.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")}' AND '#{1.day.ago.end_of_day.strftime("%Y-%m-%d %H:%M:%S")}' group by f.article_id) t on (t.article_id = articles.id)").order("count_of_last_week DESC").limit(Settings.ranking.item_count)
  }
  scope :recommended_on_last_week, -> {
    joins("inner join (select article_id, count(*) as count_of_last_week from article_recommendations r where r.created_at BETWEEN '#{1.week.ago.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")}' AND '#{1.day.ago.end_of_day.strftime("%Y-%m-%d %H:%M:%S")}' group by r.article_id) t on (t.article_id = articles.id)").order("count_of_last_week DESC").limit(Settings.ranking.item_count)
  }

  def self.count_created_on_last_month_by_user(user_id)
    count_by_sql("select count(*) from articles where user_id = #{user_id} and publicity_level <> #{Accessibility::PRIVATE} and created_at between '#{1.month.ago.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")}' and '#{1.day.ago.end_of_day.strftime("%Y-%m-%d %H:%M:%S")}'")
  end

  # get selected tags string
  def selected_tags
    @selected_tags
  end

  # sets selected tags string
  def selected_tags=(value)
    @selected_tags = value
  end

  # gets added tags string
  def added_tags
    @added_tags
  end

  # sets added tags string
  def added_tags=(value)
    @added_tags = value
  end

  validates :title, presence: true
  validates :content, presence: true
  validates :category_id, presence: true
  validates :notation_type, presence: true
  validates :publicity_level, presence: true
  # article that no tag selected cannot be acceptable
  validate  :tag_selected?

  belongs_to :user
  belongs_to :category
  has_many :feedbacks
  has_many :article_tag_rels
  has_many :tags, through: :article_tag_rels
  has_many :article_recommendations
  has_many :favorites

  # search articles and feedbacks
  # ==== Args
  # _search_word_ :: search_word: word1 word2 word3 ...
  # _page_ :: page number for pagination
  # _user_ :: current user
  # ==== Return
  # search result (articles entity array)
  def self.search(search_word, page, user)
    if search_word.blank?
      return Article.order_by_last_updated_at_desc.paginate(page: page, per_page: PER_PAGE)
    end
    articles = Article.includes(:feedbacks)
                .accessibles(user)
                .group('articles.id')
                .paginate(page: page, per_page: PER_PAGE)
    articles
  end

  # deletes itself
  def destroy
    ActiveRecord::Base.transaction do
      # delete tag rels
      tag_rels = ArticleTagRel.find_by_article_id(self.id)
      tag_rels.each do |rel|
        rel.destroy
      end
      # delete recommendations
      recommendations = ArticleRecommendation.find_by_article_id(self.id)
      recommendations.each do |recommendation|
        recommendation.destroy
      end
      # delete favorite
      favorites = Favorite.find_by_article_id(self.id)
      favorites.each do |favorite|
        favorite.destroy
      end
      # delete feedbacks
      self.feedbacks.each do |feedback|
        feedback.destroy
      end
      # logical delete article
      self.reload # clean stale object
      self.deleted_at = Time.now
      self.save!
    end
  end

  # counts entry number every feedback type
  # ==== Return
  # hash: key=feedback type, value=entry count
  def count_feedbacks_by_type
    feedbacks_counts = {}
    feedbacks_counts[Feedback::FeedbackTypes::NORMAL] = 0
    feedbacks_counts[Feedback::FeedbackTypes::SUPPLEMENT] = 0
    feedbacks_counts[Feedback::FeedbackTypes::CORRECTION] = 0
    self.feedbacks.each do |feedback|
      case feedback.feedback_type
      when Feedback::FeedbackTypes::NORMAL
        feedbacks_counts[Feedback::FeedbackTypes::NORMAL] += 1
      when Feedback::FeedbackTypes::SUPPLEMENT
        feedbacks_counts[Feedback::FeedbackTypes::SUPPLEMENT] += 1
      when Feedback::FeedbackTypes::CORRECTION
        feedbacks_counts[Feedback::FeedbackTypes::CORRECTION] += 1
      else
        feedbacks_counts[Feedback::FeedbackTypes::NORMAL] += 1
      end
    end
    feedbacks_counts
  end

  # determines whether current user recommends or not the article
  # ==== Args
  # _user_id_ :: current user id
  # ==== Return
  # true: current user recommends, false: current user does not recommend yet
  def recommended?(user_id)
    return self.article_recommendations.exists?(user_id: user_id)
  end

  # determines whether current user favors or not the article
  # ==== Args
  # _user_id_ :: current user id
  # ==== Return
  # true: current user favors, false: current user does not favor yet
  def favored?(user_id)
    return self.favorites.exists?(user_id: user_id)
  end

  # callback after save
  after_save do
    self.update_counter_cache
  end

  # callback after destroy
  after_destroy do
    self.update_counter_cache
  end

  #
  # カウンターキャッシュ。
  # Rails のカウンターキャッシュは readonly 且つ条件が指定できないため、
  # 敢えて自前で実装している。
  #
  def update_counter_cache
    self.user.articles_count = Article.count(conditions: { user_id: self.user_id })
    self.user.save!
  end

  private

  # validates whether any tag is selected for the article.
  # if no tag selected, raises validation error
  def tag_selected?
    # 入力されたタグ文字列を検証
    if self.added_tags.to_s.scan(/\[.*?\]/).blank? &&
       self.deleted_at.blank? &&
       self.tags.blank? &&
       self.selected_tags.blank?
      errors.add(:selected_tags, I18n.t('article.tag_validation_error'))
    end
  end
end
