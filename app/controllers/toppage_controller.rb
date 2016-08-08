# -*- encoding : utf-8 -*-
class ToppageController < ApplicationController

  def index
  end

  def more_tags_ranking
    @tags_ranking = Tag.well_used_tags
      .paginate(page: params["#{Toppage::Ranking::Type::TAGS}#{Toppage::Ranking::MoreLink::PAGE_PARAM_SUFFIX}".to_sym], per_page: Toppage::Ranking::PerPage::TAGS)
    render partial: 'more_ranking', locals: { model_list: @tags_ranking, ranking_type: Toppage::Ranking::Type::TAGS }
  end

  def more_article_users_ranking
    @article_users_ranking = User.heavy_users
      .paginate(page: params["#{Toppage::Ranking::Type::ARTICLE_USERS}#{Toppage::Ranking::MoreLink::PAGE_PARAM_SUFFIX}".to_sym], per_page: Toppage::Ranking::PerPage::USERS)
    render partial: 'more_ranking', locals: { model_list: @article_users_ranking, ranking_type: Toppage::Ranking::Type::ARTICLE_USERS }
  end

  def more_recommended_articles_ranking
    @recommened_articles_ranking = Article.most_recommended(current_user)
      .paginate(page: params["#{Toppage::Ranking::Type::RECOMMENDED_ARTICLES}#{Toppage::Ranking::MoreLink::PAGE_PARAM_SUFFIX}".to_sym], per_page: Toppage::Ranking::PerPage::ARTICLES)
    render partial: 'more_ranking', locals: { model_list: @recommened_articles_ranking, ranking_type: Toppage::Ranking::Type::RECOMMENDED_ARTICLES }
  end

  def more_favorite_articles_ranking
    @favorite_articles_ranking = Article.most_favorited(current_user)
      .paginate(page: params["#{Toppage::Ranking::Type::FAVORITE_ARTICLES}#{Toppage::Ranking::MoreLink::PAGE_PARAM_SUFFIX}".to_sym], per_page: Toppage::Ranking::PerPage::ARTICLES)
    render partial: 'more_ranking', locals: { model_list: @favorite_articles_ranking, ranking_type: Toppage::Ranking::Type::FAVORITE_ARTICLES }
  end

  def more_feedback_users_ranking
    @feedback_users_ranking = User.heavy_feedback_users
      .paginate(page: params["#{Toppage::Ranking::Type::FEEDBACK_USERS}#{Toppage::Ranking::MoreLink::PAGE_PARAM_SUFFIX}".to_sym], per_page: Toppage::Ranking::PerPage::USERS)
    render partial: 'more_ranking', locals: { model_list: @feedback_users_ranking, ranking_type: Toppage::Ranking::Type::FEEDBACK_USERS }
  end
end
