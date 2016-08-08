# -*- encoding : utf-8 -*-
require 'content_formatter'

class Feedback < ActiveRecord::Base
  include ContentFormatter

  default_scope -> { where(deleted_at: nil).order("last_updated_at DESC") }

  scope :article_feedback, lambda{ |article_id| where(article_id: article_id) }
  scope :recommended, -> { where("feedback_recommendations_count > 0") }
  scope :order_by_recommendations_count_desc, -> { order("feedback_recommendations_count DESC") }

  belongs_to :article
  belongs_to :user, counter_cache: true
  has_many :feedback_recommendations

  validates :content, presence: { on: :create }
  validates :user_id, presence: { on: :create }
  validates :article_id, presence: { on: :create }

  # feedback types decralation
  module FeedbackTypes
    NORMAL = 1
    SUPPLEMENT = 2
    CORRECTION = 3
    def self.to_hash
      {
        NORMAL => I18n.t('feedback.types.normal'),
        SUPPLEMENT => I18n.t('feedback.types.supplement'),
        CORRECTION => I18n.t('feedback.types.correction')
      }
    end
  end

  # deletes itself
  def destroy
    ActiveRecord::Base.transaction do
      # destroy recommendations
      recommendations = FeedbackRecommendation.find_by_feedback_id(self.id)
      recommendations.each do |recommendation|
        recommendation.destroy
      end
      # set deleted at date
      self.reload # clean stale object
      self.deleted_at = Time.now
      self.save
    end
  end

  # determines whether current user recommends or not the feedback
  # ==== Args
  # _user_id_ :: current user id
  # ==== Return
  # true: current user recommends, false: current user does not recommend yet
  def recommended?(user_id)
    return self.feedback_recommendations.exists?(user_id: user_id)
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
    self.article.feedbacks_count = Feedback.count(:conditions => { article_id: self.article_id })
    self.article.save!
  end
end
