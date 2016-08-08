# -*- encoding : utf-8 -*-
class FeedbackRecommendation < ActiveRecord::Base

  default_scope -> { where(deleted_at: nil) }
  scope :find_by_feedback_id_and_user_id, lambda {
    |feedback_id, user_id| where(feedback_id: feedback_id).where(user_id: user_id)
  }
  scope :find_by_feedback_id, lambda {
    |feedback_id| where(feedback_id: feedback_id)
  }

  belongs_to :feedback, counter_cache: true
  belongs_to :user, counter_cache: true

  # inserts new entity
  # ==== Args
  # _feedback_id_ :: target feedback id
  # _user_id_ :: current user id
  # ==== Return
  # total recommendations count of target feedback
  def self.add(feedback_id, user_id)
    FeedbackRecommendation.where(feedback_id: feedback_id, user_id: user_id).first_or_create!
    get_recommendations_count(feedback_id)
  end

  # deletes specified entity
  # ==== Args
  # _feedback_id_ :: target feedback id
  # _user_id_ :: current user id
  # ==== Return
  # total recommendations count of target feedback
  def self.delete(feedback_id, user_id)
    recommend = FeedbackRecommendation.find_by_feedback_id_and_user_id(feedback_id, user_id).first
    recommend.destroy if recommend
    get_recommendations_count(feedback_id)
  end

  private

  # gets total recommendations count for specified feedback
  # ==== Args
  # _feedback_id_ :: target feedback id
  # ==== Return
  # total recommendations count of target
  def self.get_recommendations_count(feedback_id)
    feedback = Feedback.find(feedback_id)
    feedback.feedback_recommendations_count
  rescue
    return 0
  end

end
