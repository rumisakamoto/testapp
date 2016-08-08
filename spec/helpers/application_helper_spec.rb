# -*- encoding : utf-8 -*-
require 'spec_helper'

EXAMPLE_URL      = "http://example.com/example.jpg"
EXAMPLE_NICKNAME = "るんちゃっく"
EXAMPLE_ID = 1
EXAMPLE_ARTICLES_COUNT = 50
EXAMPLE_FEEDBACKS_COUNT = 60
EXAMPLE_ARTICLE_ID = 5
EXAMPLE_ARTICLE_TITLE = "test article title"
EXAMPLE_ARTICLE_FAVORITES_COUNT = 70
EXAMPLE_ARTICLE_RECOMMENDATIONS_COUNT = 80
EXAMPLE_TAG_ID = 10
EXAMPLE_TAG_NAME = "test tag name"
EXAMPLE_TAG_ICON = EXAMPLE_URL
EXAMPLE_TAG_ARTICLE_COUNT = 90

def setup_user(id=EXAMPLE_ID)
  user = User.new
  user.icon_url = EXAMPLE_URL
  user.id = id
  user.nickname = EXAMPLE_NICKNAME
  user.articles_count = EXAMPLE_ARTICLES_COUNT
  user.feedbacks_count = EXAMPLE_FEEDBACKS_COUNT
  user
end

def setup_article(id=EXAMPLE_ARTICLE_ID)
  article = Article.new
  article.id = id
  article.title = EXAMPLE_ARTICLE_TITLE
  article.favorites_count = EXAMPLE_ARTICLE_FAVORITES_COUNT
  article.article_recommendations_count = EXAMPLE_ARTICLE_RECOMMENDATIONS_COUNT
  article
end

def setup_tag(icon_url=nil, id=EXAMPLE_TAG_ID)
  tag = Tag.new
  tag.id = id
  tag.name = EXAMPLE_TAG_NAME
  tag.icon_url = icon_url
  tag.article_tag_rels_count = EXAMPLE_TAG_ARTICLE_COUNT
  tag
end

describe ApplicationHelper do

  describe "#article_user_ranking_item" do
    context "引数 user が nil の場合" do
      it {helper.article_user_ranking_item(nil).should be_empty}
    end
    context "引数が Userクラスオブジェクト でない場合" do
      obj = Object.new
      it { proc {helper.article_user_ranking_item(obj)}.should raise_error ArgumentError }
    end
    context "引数 user の id, nickname, articles_count, icon_url がそれぞれ #{EXAMPLE_ID}, #{EXAMPLE_NICKNAME}, #{EXAMPLE_ARTICLES_COUNT}, #{EXAMPLE_URL} の場合" do
      size = Settings.icon_size.very_small
      alt  = Settings.icon.user.alt_text
      width, height = size.split("x")
      expected_icon = %Q(<img alt="#{alt}" height="#{height}" src="#{EXAMPLE_URL}" width="#{width}" />)
      expected_ref = "/users/#{EXAMPLE_ID}"
      expected = %Q(<li><a href="#{expected_ref}">#{expected_icon} #{EXAMPLE_NICKNAME} (#{EXAMPLE_ARTICLES_COUNT})</a></li>)
      # delete white spaces
      expected.gsub!(/\s/, "")
      user = setup_user
      it {
        # delete white spaces
        target = helper.article_user_ranking_item(user).gsub(/\s/, "")
        target.should == expected
      }
    end
  end

  describe "#feedback_user_ranking_item" do
    context "引数 user が nil の場合" do
      it {helper.feedback_user_ranking_item(nil).should be_empty}
    end
    context "引数が Userクラスオブジェクト でない場合" do
      obj = Object.new
      it { proc {helper.feedback_user_ranking_item(obj)}.should raise_error ArgumentError }
    end
    context "引数 user の id, nickname, feedbacks_count, icon_url がそれぞれ #{EXAMPLE_ID}, #{EXAMPLE_NICKNAME}, #{EXAMPLE_FEEDBACKS_COUNT}, #{EXAMPLE_URL} の場合" do
      size = Settings.icon_size.very_small
      alt  = Settings.icon.user.alt_text
      width, height = size.split("x")
      expected_icon =%Q(<img alt="#{alt}" height="#{height}" src="#{EXAMPLE_URL}" width="#{width}" />)
      expected_ref = "/users/#{EXAMPLE_ID}"
      expected = %Q(<li><a href="#{expected_ref}">#{expected_icon} #{EXAMPLE_NICKNAME} (#{EXAMPLE_FEEDBACKS_COUNT})</a></li>)
      expected.gsub!(/\s/, "")
      user = setup_user
      it {
        target = helper.feedback_user_ranking_item(user).gsub(/\s/, "")
        target.should == expected
      }
    end
  end

  describe "#favorite_article_ranking_item" do
    context "引数 article が nil の場合" do
      it {helper.favorite_article_ranking_item(nil).should be_empty}
    end
    context "引数が Articleクラスオブジェクト でない場合" do
      obj = Object.new
      it { proc {helper.favorite_article_ranking_item(obj)}.should raise_error NoMethodError }
    end
    context "引数 article の id, title, favorites_count がそれぞれ #{EXAMPLE_ARTICLE_ID}, #{EXAMPLE_ARTICLE_TITLE}, #{EXAMPLE_ARTICLE_FAVORITES_COUNT} の場合" do
      expected_icon = %Q(<i class="icon-bookmark"></i>)
      expected_ref = "/articles/#{EXAMPLE_ARTICLE_ID}"
      expected = %Q(<li><a href="#{expected_ref}">#{expected_icon} #{EXAMPLE_ARTICLE_TITLE} (#{EXAMPLE_ARTICLE_FAVORITES_COUNT})</a></li>)
      expected.gsub!(/\s/, "")
      article = setup_article
      it {
        target = helper.favorite_article_ranking_item(article).gsub(/\s/, "")
        target.should == expected
      }
    end
  end

  describe "#recommended_article_ranking_item" do
    context "引数 article が nil の場合" do
      it {helper.recommended_article_ranking_item(nil).should be_empty}
    end
    context "引数が Articleクラスオブジェクト でない場合" do
      obj = Object.new
      it { proc {helper.recommended_article_ranking_item(obj)}.should raise_error NoMethodError }
    end
    context "引数 article の id, title, recommandations_count がそれぞれ #{EXAMPLE_ARTICLE_ID}, #{EXAMPLE_ARTICLE_TITLE}, #{EXAMPLE_ARTICLE_RECOMMENDATIONS_COUNT} の場合" do
      expected_icon = '<i class="icon-thumbs-up"></i>'
      expected_ref = "/articles/#{EXAMPLE_ARTICLE_ID}"
      expected = %Q(<li><a href="#{expected_ref}">#{expected_icon} #{EXAMPLE_ARTICLE_TITLE} (#{EXAMPLE_ARTICLE_RECOMMENDATIONS_COUNT})</a></li>)
      expected.gsub!(/\s/, "")
      article = setup_article
      it {
        target = helper.recommended_article_ranking_item(article).gsub(/\s/, "")
        target.should == expected
      }
    end
  end

  describe "#tag_ranking_item" do
    context "引数 tag が nil の場合" do
      it {helper.tag_ranking_item(nil).should be_empty}
    end
    context "引数が Tagクラスオブジェクト でない場合" do
      obj = Object.new
      it { proc {helper.favorite_tag_ranking_item(obj)}.should raise_error NoMethodError }
    end
    context "引数 tag の id, icon_url, name, article_tag_rels_count がそれぞれ #{EXAMPLE_TAG_ID}, nil, #{EXAMPLE_TAG_NAME}, #{EXAMPLE_TAG_ARTICLE_COUNT} の場合" do
      expected_ref = "/articles/tags/#{EXAMPLE_TAG_ID}"
      expected_icon = '<i class="icon-tag"></i>'
      expected = %Q(<li><a href="#{expected_ref}">#{expected_icon} #{EXAMPLE_TAG_NAME} (#{EXAMPLE_TAG_ARTICLE_COUNT})</a></li>)
      expected.gsub!(/\s/, "")
      tag = setup_tag(nil)
      it {
        target = helper.tag_ranking_item(tag).gsub(/\s/, "")
        target.should == expected
      }
    end
    context "引数 tag の id, icon_url, name, article_tag_rels_count がそれぞれ #{EXAMPLE_TAG_ID},#{EXAMPLE_TAG_ICON}, #{EXAMPLE_TAG_NAME}, #{EXAMPLE_TAG_ARTICLE_COUNT} の場合" do
      expected_ref = "/articles/tags/#{EXAMPLE_TAG_ID}"
      width, height = Settings.icon_size.very_small.split("x")
      expected_icon = %Q(<img src="#{EXAMPLE_TAG_ICON}" height="#{height}" width="#{width}"/>)
      expected = %Q(<li><a href="#{expected_ref}">#{expected_icon} #{EXAMPLE_TAG_NAME} (#{EXAMPLE_TAG_ARTICLE_COUNT})</a></li>)
      expected.gsub!(/\s/, "")
      tag = setup_tag(EXAMPLE_TAG_ICON)
      it {
        target = helper.tag_ranking_item(tag).gsub(/\s/, "")
        target.should == expected
      }
    end
  end

  describe "#more_ranking_link" do
    context "引数 model_list, ranking_type が nil の場合" do
      it {helper.more_ranking_link(nil, nil).should be_empty}
    end
    page = 1;    per_page = 5;    total = 15;    model_list = nil
    context "引数 ranking_type が #{Toppage::Ranking::Type::TAGS} の場合" do
      ranking_type = Toppage::Ranking::Type::TAGS
      before do
        model_list = WillPaginate::Collection.new page, per_page, total
        total.times do |i|
          model_list << setup_tag(nil, i + 1)
        end
      end
      it "文字列が生成されること" do
        helper.more_ranking_link(model_list, ranking_type).should_not be_empty
      end
      it "リンクが生成されること" do
        helper.more_ranking_link(model_list, ranking_type).should match(/<a\s/)
      end
      it "リンクに id=\"more_#{ranking_type}_ranking_link\" がつくこと" do
        id = "id=\"more_#{ranking_type}_ranking_link\""
        helper.more_ranking_link(model_list, ranking_type).should match(id)
      end
      it "リンク先が href=\"/toppage/more_#{ranking_type}_ranking?#{ranking_type}_ranking_page=#{page + 1}\" になること" do
        href = Regexp.escape "href=\"/toppage/more_#{ranking_type}_ranking?#{ranking_type}_ranking_page=#{model_list.next_page}\""
        helper.more_ranking_link(model_list, ranking_type).should match(href)
      end
      it "ラベルが #{I18n.t('more')} になること" do
        label = Regexp.escape ">#{I18n.t('more')}</"
        helper.more_ranking_link(model_list, ranking_type).should match(label)
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::ARTICLE_USERS} の場合" do
      ranking_type = Toppage::Ranking::Type::ARTICLE_USERS
      before do
        model_list = WillPaginate::Collection.new page, per_page, total
        total.times do |i|
          model_list << setup_user(i + 1)
        end
      end
      it "文字列が生成されること" do
        helper.more_ranking_link(model_list, ranking_type).should_not be_empty
      end
      it "リンクが生成されること" do
        helper.more_ranking_link(model_list, ranking_type).should match(/<a\s/)
      end
      it "リンクに id=\"more_#{ranking_type}_ranking_link\" がつくこと" do
        id = "id=\"more_#{ranking_type}_ranking_link\""
        helper.more_ranking_link(model_list, ranking_type).should match(id)
      end
      it "リンク先が href=\"/toppage/more_#{ranking_type}_ranking?#{ranking_type}_ranking_page=#{page + 1}\" になること" do
        href = Regexp.escape "href=\"/toppage/more_#{ranking_type}_ranking?#{ranking_type}_ranking_page=#{model_list.next_page}\""
        helper.more_ranking_link(model_list, ranking_type).should match(href)
      end
      it "ラベルが #{I18n.t('more')} になること" do
        label = Regexp.escape ">#{I18n.t('more')}</"
        helper.more_ranking_link(model_list, ranking_type).should match(label)
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::FEEDBACK_USERS} の場合" do
      ranking_type = Toppage::Ranking::Type::FEEDBACK_USERS
      before do
        model_list = WillPaginate::Collection.new page, per_page, total
        total.times do |i|
          model_list << setup_user(i + 1)
        end
      end
      it "文字列が生成されること" do
        helper.more_ranking_link(model_list, ranking_type).should_not be_empty
      end
      it "リンクが生成されること" do
        helper.more_ranking_link(model_list, ranking_type).should match(/<a\s/)
      end
      it "リンクに id=\"more_#{ranking_type}_ranking_link\" がつくこと" do
        id = "id=\"more_#{ranking_type}_ranking_link\""
        helper.more_ranking_link(model_list, ranking_type).should match(id)
      end
      it "リンク先が href=\"/toppage/more_#{ranking_type}_ranking?#{ranking_type}_ranking_page=#{page + 1}\" になること" do
        href = Regexp.escape "href=\"/toppage/more_#{ranking_type}_ranking?#{ranking_type}_ranking_page=#{model_list.next_page}\""
        helper.more_ranking_link(model_list, ranking_type).should match(href)
      end
      it "ラベルが #{I18n.t('more')} になること" do
        label = Regexp.escape ">#{I18n.t('more')}</"
        helper.more_ranking_link(model_list, ranking_type).should match(label)
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::RECOMMENDED_ARTICLES} の場合" do
      ranking_type = Toppage::Ranking::Type::RECOMMENDED_ARTICLES
      before do
        model_list = WillPaginate::Collection.new page, per_page, total
        total.times do |i|
          model_list << setup_article(i + 1)
        end
      end
      it "文字列が生成されること" do
        helper.more_ranking_link(model_list, ranking_type).should_not be_empty
      end
      it "リンクが生成されること" do
        helper.more_ranking_link(model_list, ranking_type).should match(/<a\s/)
      end
      it "リンクに id=\"more_#{ranking_type}_ranking_link\" がつくこと" do
        id = "id=\"more_#{ranking_type}_ranking_link\""
        helper.more_ranking_link(model_list, ranking_type).should match(id)
      end
      it "リンク先が href=\"/toppage/more_#{ranking_type}_ranking?#{ranking_type}_ranking_page=#{page + 1}\" になること" do
        href = Regexp.escape "href=\"/toppage/more_#{ranking_type}_ranking?#{ranking_type}_ranking_page=#{model_list.next_page}\""
        helper.more_ranking_link(model_list, ranking_type).should match(href)
      end
      it "ラベルが #{I18n.t('more')} になること" do
        label = Regexp.escape ">#{I18n.t('more')}</"
        helper.more_ranking_link(model_list, ranking_type).should match(label)
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::FAVORITE_ARTICLES} の場合" do
      ranking_type = Toppage::Ranking::Type::FAVORITE_ARTICLES
      before do
        model_list = WillPaginate::Collection.new page, per_page, total
        total.times do |i|
          model_list << setup_article(i + 1)
        end
      end
      it "文字列が生成されること" do
        helper.more_ranking_link(model_list, ranking_type).should_not be_empty
      end
      it "リンクが生成されること" do
        helper.more_ranking_link(model_list, ranking_type).should match(/<a\s/)
      end
      it "リンクに id=\"more_#{ranking_type}_ranking_link\" がつくこと" do
        id = "id=\"more_#{ranking_type}_ranking_link\""
        helper.more_ranking_link(model_list, ranking_type).should match(id)
      end
      it "リンク先が href=\"/toppage/more_#{ranking_type}_ranking?#{ranking_type}_ranking_page=#{page + 1}\" になること" do
        href = Regexp.escape "href=\"/toppage/more_#{ranking_type}_ranking?#{ranking_type}_ranking_page=#{model_list.next_page}\""
        helper.more_ranking_link(model_list, ranking_type).should match(href)
      end
      it "ラベルが #{I18n.t('more')} になること" do
        label = Regexp.escape ">#{I18n.t('more')}</"
        helper.more_ranking_link(model_list, ranking_type).should match(label)
      end
    end
  end

  describe "#ranking_item" do
    context "引数 model, ranking_type がそれぞれ nil の場合" do
      it {helper.ranking_item(nil, nil).should be_empty}
    end
    context "引数 ranking_type が Toppage::Ranking::Type に定義されていない値の場合" do
      ranking_type = "dummy"
      context "引数 model が Userクラス の場合" do
        model = setup_user
        it { helper.ranking_item(model, ranking_type).should be_empty }
      end
      context "引数 model が Articleクラス の場合" do
        model = setup_article
        it { helper.ranking_item(model, ranking_type).should be_empty }
      end
      context "引数 model が Tagクラス の場合" do
        model = setup_tag
        it { helper.ranking_item(model, ranking_type).should be_empty }
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::FEEDBACK_USERS} の場合" do
      ranking_type = Toppage::Ranking::Type::FEEDBACK_USERS
      context "引数 model が nil の場合" do
        it {helper.ranking_item(nil, ranking_type).should be_empty}
      end
      context "引数 model が Userクラス ではない場合" do
        model = Object.new
        it {helper.ranking_item(model, ranking_type).should be_empty}
      end
      context "引数 model が Userクラス の場合" do
        target = nil
        before do
          model = setup_user
          target = helper.ranking_item(model, ranking_type)
        end
        it "文字列が生成されること" do
          target.should_not be_empty
        end
        it "リンクタグが生成されること" do
          target.should match(/<a\s/)
        end
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::ARTICLE_USERS} の場合" do
      ranking_type = Toppage::Ranking::Type::ARTICLE_USERS
      context "引数 model が nil の場合" do
        it {helper.ranking_item(nil, ranking_type).should be_empty}
      end
      context "引数 model が Userクラス ではない場合" do
        model = Object.new
        it {helper.ranking_item(model, ranking_type).should be_empty}
      end
      context "引数 model が Userクラス の場合" do
        target = nil
        before do
          model = setup_user
          target = helper.ranking_item(model, ranking_type)
        end
        it "文字列が生成されること" do
          target.should_not be_empty
        end
        it "リンクタグが生成されること" do
          target.should match(/<a\s/)
        end
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::FAVORITE_ARTICLES} の場合" do
      ranking_type = Toppage::Ranking::Type::FAVORITE_ARTICLES
      context "引数 model が nil の場合" do
        it {helper.ranking_item(nil, ranking_type).should be_empty}
      end
      context "引数 model が Articleクラス ではない場合" do
        model = Object.new
        it {helper.ranking_item(model, ranking_type).should be_empty}
      end
      context "引数 model が Articleクラス の場合" do
        target = nil
        before do
          model = setup_article
          target = helper.ranking_item(model, ranking_type)
        end
        it "文字列が生成されること" do
          target.should_not be_empty
        end
        it "リンクタグが生成されること" do
          target.should match(/<a\s/)
        end
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::TAGS} の場合" do
      ranking_type = Toppage::Ranking::Type::TAGS
      context "引数 model が nil の場合" do
        it {helper.ranking_item(nil, ranking_type).should be_empty}
      end
      context "引数 model が Tagクラス ではない場合" do
        model = Object.new
        it {helper.ranking_item(model, ranking_type).should be_empty}
      end
      context "引数 model が Tagクラス の場合" do
        target = nil
        before do
          model = setup_tag
          target = helper.ranking_item(model, ranking_type)
        end
        it "文字列が生成されること" do
          target.should_not be_empty
        end
        it "リンクタグが生成されること" do
          target.should match(/<a\s/)
        end
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::RECOMMENDED_ARTICLES} の場合" do
      ranking_type = Toppage::Ranking::Type::RECOMMENDED_ARTICLES
      context "引数 model が nil の場合" do
        it {helper.ranking_item(nil, ranking_type).should be_empty}
      end
      context "引数 model が Articleクラス ではない場合" do
        model = Object.new
        it {helper.ranking_item(model, ranking_type).should be_empty}
      end
      context "引数 model が Articleクラス の場合" do
        target = nil
        before do
          model = setup_article
          target = helper.ranking_item(model, ranking_type)
        end
        it "文字列が生成されること" do
          target.should_not be_empty
        end
        it "リンクタグが生成されること" do
          target.should match(/<a\s/)
        end
      end
    end
  end

  describe "#ranking_list" do
    context "引数 model_list, ranking_type がそれぞれ nil の場合" do
      it { helper.ranking_list(nil, nil).should be_empty }
    end
    array_num = 10
    context "引数 ranking_type が Toppage::Ranking::Type に定義されていない値の場合" do
      ranking_type = "dummy"
      context "引数 model_list が Tagクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_tag(nil, i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
      context "引数 model_list が Articleクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_article(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
      context "引数 model_list が Userクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_user(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::FEEDBACK_USERS} の場合" do
      ranking_type = Toppage::Ranking::Type::FEEDBACK_USERS
      context "引数 model_list が Tagクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_tag(nil, i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
      context "引数 model_list が Articleクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_article(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
      context "引数 model_list が Userクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_user(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should_not be_empty }
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::ARTICLE_USERS} の場合" do
      ranking_type = Toppage::Ranking::Type::ARTICLE_USERS
      context "引数 model_list が Tagクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_tag(nil, i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
      context "引数 model_list が Articleクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_article(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
      context "引数 model_list が Userクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_user(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should_not be_empty }
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::RECOMMENDED_ARTICLES} の場合" do
      ranking_type = Toppage::Ranking::Type::RECOMMENDED_ARTICLES
      context "引数 model_list が Tagクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_tag(nil, i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
      context "引数 model_list が Articleクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_article(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should_not be_empty }
      end
      context "引数 model_list が Userクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_user(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::FAVORITE_ARTICLES} の場合" do
      ranking_type = Toppage::Ranking::Type::FAVORITE_ARTICLES
      context "引数 model_list が Tagクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_tag(nil, i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
      context "引数 model_list が Articleクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_article(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should_not be_empty }
      end
      context "引数 model_list が Userクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_user(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
    end
    context "引数 ranking_type が #{Toppage::Ranking::Type::TAGS} の場合" do
      ranking_type = Toppage::Ranking::Type::TAGS
      context "引数 model_list が Tagクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_tag(nil, i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should_not be_empty }
      end
      context "引数 model_list が Articleクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_article(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
      context "引数 model_list が Userクラス の配列の場合" do
        model_list = []
        array_num.times do |i|
          model_list << setup_user(i + 1)
        end
        it { helper.ranking_list(model_list, ranking_type).should be_empty }
      end
    end
  end

  describe "#side_menu_title" do
    context "引数 resource_key が nil の場合" do
      it { helper.side_menu_title(nil).should be_empty }
    end
    context "引数 resource_key が ranking.tags の場合" do
      resource_key = "ranking.tags"
      it "文字列が生成されること" do
        helper.side_menu_title(resource_key).should_not be_empty
      end
      it "h3タグが生成されること" do
        helper.side_menu_title(resource_key).should match(/<h3>.+<\/h3>/)
      end
    end
  end

  describe "#since_updated" do
    context "引数 time が nil の場合" do
      it { helper.since_updated(nil).should be_empty }
    end
    context "引数 time が 任意の時刻(Time.now) の場合" do
      time = Time.now
      it "文字列が生成されること" do
        helper.since_updated(time).should_not be_empty
      end
      it "末尾が #{I18n.t('time_ago')} になること" do
        helper.since_updated(time).should match(/#{I18n.t('time_ago')}$/)
      end
    end
  end

  describe "#page_title" do
    context "uers#index の場合" do
      before do
        helper.stub!(:controller_name).and_return('users')
        helper.stub!(:action_name).and_return('index')
        @target = helper.page_title.gsub(/\s|\n/, "")
      end
      it "文字列が生成されること" do
        @target.should_not be_empty
      end
      it "translation.missing が含まれないこと" do
        @target.should_not match(/translation\.missing/)
      end
      it "divタグ(class=\"page-header\") とそのタグ内に h1タグ が出力されること" do
        @target.should match(/^<div.*class="page-header".*<h1>.+<\/h1><\/div>$/)
      end
    end
  end

  describe "#user_icon" do
    alt = Settings.icon.user.alt_text
    context "引数 user, size が nil の場合" do
      size = Settings.icon_size.medium
      width, height = size.split("x")
      nickname = I18n.t('guest_name')
      expected = %Q(<img alt="#{alt}" height="#{height}" src="#{Settings.icon.user.default_image_url}" width="#{width}" /> #{nickname})
      it {helper.user_icon(nil, nil).should == expected}
    end
    context "引数 size が 50x45の場合" do
      size = "50x45"
      width, height = size.split("x")
      context "引数 user を設定した場合" do
        user = setup_user
        expected_ref = "/users/#{user.id}"
        expected = <<-HTML
        <a href="#{expected_ref}"><img alt="#{alt}" height="#{height}" src="#{EXAMPLE_URL}" width="#{width}" /> #{EXAMPLE_NICKNAME}</a>
        HTML
        expected.gsub!(/\s/, "")
        it { helper.user_icon(size, user).gsub!(/\s/, "").should eql expected }
      end
    end
  end

  describe "#user_icon_large" do
    size = Settings.icon_size.large
    alt  = Settings.icon.user.alt_text
    width, height = size.split("x")
    context "引数 user が nil の場合" do
      nickname = I18n.t('guest_name')
      expected = %Q(<img alt="#{alt}" height="#{height}" src="#{Settings.icon.user.default_image_url}" width="#{width}" /><font size='#{Settings.font_size_addition.large}'> #{nickname}</font>)
      it {helper.user_icon_large(nil).should == expected}
    end
    context "引数 user を設定した場合" do
      user = setup_user
      expected = %Q(<img alt="#{alt}" height="#{height}" src="#{EXAMPLE_URL}" width="#{width}" /><font size='#{Settings.font_size_addition.large}'> #{EXAMPLE_NICKNAME}</font>)
      it { helper.user_icon_large(user).should eql expected }
    end
  end

  describe "#icon_name" do
    context "引数 user が nil の場合" do
      expected_url = Settings.icon.user.guest_image
      it {helper.icon_name(nil).should == expected_url}
    end
    context "引数 user の icon_url が nil の場合" do
      expected_url = Settings.icon.user.guest_image
      user = User.new
      it {helper.icon_name(user).should == expected_url}
    end
    context "引数 user の icon_url が #{EXAMPLE_URL} に設定されている場合" do
      user = setup_user
      it {helper.icon_name(user).should == EXAMPLE_URL}
    end
  end

  describe "#nickname" do
    context "引数 user が nil の場合" do
      expected_name = I18n.t('guest_name')
      it {helper.nickname(nil).should == expected_name}
    end
    context "引数 user の nickname が #{EXAMPLE_NICKNAME} に設定されている場合" do
      user = setup_user
      it {helper.nickname(user).should == EXAMPLE_NICKNAME}
    end
  end

  describe "#user_icon_image_tag" do
    context "引数 image が空文字列の場合" do
      it {helper.user_icon_image_tag("").should == ""}
    end
    context "引数 image が文字列(#{EXAMPLE_URL})の場合" do
      size = Settings.icon_size.medium
      alt  = Settings.icon.user.alt_text
      width, height = size.split("x")
      expected_url = %Q(<img alt="#{alt}" height="#{height}" src="#{EXAMPLE_URL}" width="#{width}" />)
      it {helper.user_icon_image_tag(EXAMPLE_URL).should == expected_url}
    end
    context "引数 image が icon_url プロパティに文字列(#{EXAMPLE_URL}) を設定されたモデルの場合" do
      size = Settings.icon_size.medium
      alt  = Settings.icon.user.alt_text
      width, height = size.split("x")
      expected_url = %Q(<img alt="#{alt}" height="#{height}" src="#{EXAMPLE_URL}" width="#{width}" />)
      user = User.new
      user.icon_url = EXAMPLE_URL
      it {helper.user_icon_image_tag(user).should == expected_url}
    end
    context "引数 image が icon_url プロパティが空のモデルの場合" do
      size = Settings.icon_size.medium
      alt  = Settings.icon.user.alt_text
      width, height = size.split("x")
      expected_url = %Q(<img alt="#{alt}" height="#{height}" src="#{Settings.icon.user.default_image_url}" width="#{width}" />)
      user = User.new
      it {helper.user_icon_image_tag(user).should == expected_url}
    end
    context "引数 image にサポート外のクラスが渡された場合" do
      it {proc {helper.user_icon_image_tag(:foo)}.should raise_error(ArgumentError)}
    end
  end

  describe "#error_messages" do
    context "引数 resource が nil の場合" do
      it { helper.error_messages(nil).should be_empty }
    end
    context "引数 resource が ActiveModel::Errors型の errorsプロパティ をもたない場合" do
      obj = Object.new
      it { proc { helper.error_messages(obj) }.should raise_error NoMethodError }
    end
    context "引数 resource が バリデーションエラーを起こしていない場合" do
      obj = User.new
      it { helper.error_messages(obj).should be_empty }
    end
    context "引数 resouce が バリデーションエラーを起こしている場合" do
      before do
        obj = User.new
        obj.valid?
        @target = helper.error_messages(obj).gsub(/\n/, "")
      end
      it "文字列が生成されること" do
        @target.should_not be_empty
      end
      it "div, a, h4, ul タグが生成されること" do
        @target.should match(/<div.+ alert-error.+<a.+<\/a>.*<h4.+<\/h4>.*<ul>.+<\/ul>.*<\/div>/)
      end
      it "#{I18n.t('error_title')} が表示されること" do
        @target.should match(/#{I18n.t('error_title')}/)
      end
    end
  end

  describe "#ajax_error_messages" do
    context "引数 resource_key が nil の場合" do
      it { helper.ajax_error_messages(nil).should be_empty }
    end
    context "引数 resource_key が ranking.load_error の場合" do
      resource_key = 'ranking.load_error'
      expected = <<-HTML
      <span class="label label-important">#{t(resource_key)}#{t('error_ajax')}</span>
      HTML
      expected.gsub!(/\s/, "")
      before do
        @target = helper.ajax_error_messages(resource_key).gsub(/\s/, "")
      end
      it "文字列が生成されること" do
        @target.should_not be_empty
      end
      it "/^<span.*class=\"labellabel-important\">#{I18n.t(resource_key)}#{I18n.t('error_ajax')}.*<\/span>$/にマッチすること" do
        @target.should match(/^<span.*class=\"labellabel-important\">#{I18n.t(resource_key)}#{I18n.t('error_ajax')}.*<\/span>$/)
      end
    end
  end

  describe "#notice_messages" do
    context "notice が nil の場合" do
      before do
        helper.stub!(:notice).and_return(nil)
      end
      it { helper.notice_messages.should be_empty }
    end
    context "notice が文字列の場合" do
      before do
        @expected = 'notice_message'
        helper.stub!(:notice).and_return(@expected)
      end
      it "文字列が生成されること" do
        helper.notice_messages.should_not be_empty
      end
      it "<li>notice_messages</li> にマッチすること" do
        helper.notice_messages.should match(/<li>#{@expected}<\/li>/)
      end
    end
    context "notice が配列の場合" do
      message_num = 10
      message_body = "notice_message "
      before do
        @expected = []
        message_num.times { |i| @expected << "#{message_body}#{i}" }
        helper.stub!(:notice).and_return(@expected)
        @target = helper.notice_messages.gsub(/\n/, "")
      end
      it "文字列が生成されること" do
        @target.should_not be_empty
      end
      it "div, a, h4, ul タグが生成されること" do
        @target.should match(/<div.+alert-info.+<a.+<\/a>.*<h4.+<\/h4>.*<ul>.+<\/ul>.*<\/div>/)
      end
      it "#{I18n.t('notice_title')} が表示されること" do
        @target.should match(/#{I18n.t('notice_title')}/)
      end
      it "notice messageの数だけ <li>notice_message i</li> にマッチすること" do
        result = true
        message_num.times { |i| result &= !@target.match(/<li>#{message_body}#{i}<\/li>/).blank? }
        result.should be_true
      end
    end
  end

  describe "#alert_messages" do
    context "引数 alert_messages が nil の場合" do
      context "alert が nil の場合" do
        before do
          helper.stub!(:alert).and_return(nil)
        end
        it { helper.alert_messages(nil).should be_empty }
      end
      context "alert が 文字列の場合" do
        alert = "alert message"
        before do
          helper.stub!(:alert).and_return(alert)
        end
        it "#{alert} にマッチすること" do
          helper.alert_messages(nil).should match(alert)
        end
      end
      context "alert が 配列の場合" do
        system_alerts = []; alert_num = 5; alert = "alert "
        before do
          alert_num.times { |i| system_alerts << "#{alert}#{i}"; system_alerts << ""; }
          helper.stub!(:alert).and_return(system_alerts)
          @target = helper.alert_messages(nil).gsub(/\n/, "")
        end
        it "div, a, h4, ul タグが生成されること" do
          @target.should match(/<div.+alert-block.+<a.+<\/a>.*<h4.+<\/h4>.*<ul>.+<\/ul>.*<\/div>/)
        end
        it "#{I18n.t('alert_title')} が表示されること" do
          @target.should match(/#{I18n.t('alert_title')}/)
        end
        it "alert 配列内のすべての文字列にマッチすること" do
          result = true
          alert_num.times { |i| result &= !@target.match(/<li>#{alert}#{i}<\/li>/).blank? }
          result.should be_true
        end
      end
    end
    context "引数 alert_messages が文字列の場合" do
      custom_alert = "custom_alert"; alert = "alert "
      context "alert が文字列の場合" do
        before do
          helper.stub!(:alert).and_return(alert)
          @target = helper.alert_messages(custom_alert).gsub(/\n/, "")
        end
        it { @target.should match(/<li>#{custom_alert}<\/li>/) }
        it { @target.should match(/<li>#{alert}<\/li>/) }
      end
      system_alerts = []; alert_num = 5
      context "alert が配列の場合" do
        before do
          alert_num.times { |i| system_alerts << "#{alert}#{i}"; system_alerts << "" }
          helper.stub!(:alert).and_return(system_alerts)
          @target = helper.alert_messages(custom_alert)
        end
        it "<li>#{custom_alert}</li> にマッチすること" do
          @target.should match(/<li>#{custom_alert}<\/li>/)
        end
        it "<li>#{alert}</li> にマッチすること" do
          result = true
          alert_num.times { |i| result &= !@target.match(/<li>#{alert}#{i}<\/li>/).blank? }
          result.should be_true
        end
      end
    end
    context "引数 alert_messages が配列の場合" do
      custom_alert = "custom_alert"; alert = "alert "; custom_alert_num = 10; custom_alerts = []
      context "alert が文字列の場合" do
        before do
          helper.stub!(:alert).and_return(alert)
          custom_alert_num.times { |i| custom_alerts << "#{custom_alert}#{i}"; custom_alerts << "" }
          @target = helper.alert_messages(custom_alerts).gsub(/\n/, "")
        end
        it "<li>#{custom_alert}</li> にマッチすること" do
          @target.should match(/#{custom_alert}/)
        end
        it { @target.should match(/#{alert}/) }
      end
      system_alerts = []; alert_num = 5
      context "alert が配列の場合" do
        before do
          alert_num.times { |i| system_alerts << "#{alert}#{i}"; system_alerts << "" }
          helper.stub!(:alert).and_return(system_alerts)
          @target = helper.alert_messages(custom_alert)
        end
        it "<li>#{custom_alert}</li> にマッチすること" do
          result = true
          custom_alert_num.times { |i| result &= !@target.match(/<li>#{custom_alert}#{i}<\/li>/).blank? }
        end
        it "<li>#{alert}</li> にマッチすること" do
          result = true
          alert_num.times { |i| result &= !@target.match(/<li>#{alert}#{i}<\/li>/).blank? }
          result.should be_true
        end
      end
    end
  end
end
