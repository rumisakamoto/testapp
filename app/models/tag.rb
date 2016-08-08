# -*- encoding : utf-8 -*-
require 'nkf'

class Tag < ActiveRecord::Base

  PER_PAGE = 12

  validates :name, presence: true
  validates :user_id, presence: true
  before_destroy do |tag|
      tag.article_tag_rels_count == 0
  end

  default_scope -> {where(deleted_at: nil) }
  scope :find_by_user_id, lambda{ |user_id| where(user_id: user_id) }
  scope :find_by_name, lambda{ |name| where(name: name) }
  scope :order_by_name, -> { order('name asc') }
  scope :well_used_tags, -> { order('article_tag_rels_count desc').where('article_tag_rels_count > 0') }

  has_many :article_tag_rels
  has_many :articles, through: :article_tag_rels

  # gets entity of user who created the tag
  def creator
    user = User.find(user_id)
    user
  end

  def selected?(article)
    if article.tags.blank?
      return false
    end
    article.tags.each do |selected_tag|
      if self.id == selected_tag.id
        return true
      end
    end
    return false
  end

  def self.find_or_create!(name, user_id)
    tag = Tag.find_by_name(name).first
    unless tag
      tag = Tag.new
      tag.name = name
      tag.user_id = user_id
      tag.save!
    end
    tag
  end

  # タグを保存する
  # ==== Args
  # _selected_tags_ :: タグ文字列
  # _article_id_ :: 記事ID
  # _user_id_ :: ユーザID
  def self.save_tags!(selected_tags, article_id, user_id)
    # 現在の記事とタグの関連を取得
    previous_tag_rels = ArticleTagRel.find_by_article_id(article_id)
    new_tag_rels = []
    # 入力されたタグ文字列ごとに
    selected_tags.scan(/\[.*?\]/).each do |tag_name|
      # タグ名を取得
      tag_name = parse(tag_name)
      unless tag_name
        next
      end
      # タグを(同じ名前がテーブルになければ)新規作成またはロード
      tag = find_or_create!(tag_name, user_id)
      # 関連を追加またはロード
      rel = ArticleTagRel.touch_or_create(article_id, tag)
      new_tag_rels << rel
    end
    # 削除されたタグは関連を削除
    unused_tag_rels = previous_tag_rels - new_tag_rels
    unused_tag_rels.each do |rel|
      rel.destroy!
    end
  end

  private

  # 与えられたタグ文字列を正規化する
  # 開始文字[を削除
  # 終了文字]を削除
  # 全角記号 => 半角記号
  # 半角カタカナ => 全角カタカナ
  # 全角英数 => 半角英数
  # ==== Args
  # _text_ :: 正規化する文字列
  # ==== Return
  # 正規化された文字列
  def self.parse(text)
    text.force_encoding(Encoding::UTF_8)
    text.gsub!(/^\[|\]$/, "")
    text.tr!('！？（）＜＞＝［］｛｝＼・', '\!\?\(\)\<\>\=\[\]\{\}\\/')
    parsed_text = NKF.nkf('-WsXm0Z0', text)
    if parsed_text.empty?
      return nil
    end
    parsed_text
  end
end
