# -*- encoding : utf-8 -*-
class ArticleTagRel < ActiveRecord::Base

  default_scope -> { where(deleted_at: nil) }
  scope :find_by_article_id_and_tag_id, lambda {
    |article_id, tag_id| where(article_id: article_id).where(tag_id: tag_id)
  }
  scope :find_by_article_id, lambda {
    |article_id| where(article_id: article_id)
  }
  scope :find_by_tag_id, lambda {
    |tag_id| where(tag_id: tag_id)
  }

  belongs_to :article, counter_cache: true
  belongs_to :tag, counter_cache: true

  def self.touch_or_create(article_id, tag)
    rel = ArticleTagRel.find_by_article_id_and_tag_id(article_id, tag.id).first
    if rel
      rel.touch
    else
      rel = ArticleTagRel.new
      rel.article_id = article_id
      rel.tag = tag
      rel.save
    end
    rel
  end
end
