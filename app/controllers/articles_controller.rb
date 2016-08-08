# -*- encoding : utf-8 -*-
require 'content_formatter'

class ArticlesController < ApplicationController

  # require login before following action
  before_filter :require_login,
    only: [:new, :create, :edit, :update, :destroy, :preview, :recommend, :favor, :recently_created_articles]
  before_filter only: [:new, :create, :edit, :update] do
    @publicities = Accessibility.selections(current_user)
  end
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'text' }
  #before_filter :auto_login, only: [:recently_created_articles]
  #skip_before_filter :require_login, only: [:new], if: :from_desktop?

  # action accessing controlled by user role with cancan
  load_and_authorize_resource

  # renders articles recently created info in xml
  # (for desktop application)
  def recently_created_articles
    # 現在時刻から指定分前または1時間前までの間に登録された記事を取得する
    if params[:minutes]
        passed = params[:minutes].to_i
    else
        passed = 60
    end
    target_datetime = Time.current.ago passed.minutes
    @articles = Article.accessibles(current_user).recently_created(@user, target_datetime)
    logger.debug target_datetime
    respond_to do |format|
      format.text{ render text: @articles.to_xml(include: { user: { only: [:nickname] } }, only: [:id, :user_id, :title, :created_at]), layout: false }
    end
    #skip_types: true, dasherize: false,
  rescue
    respond_to do |format|
      format.text { render text: get_resource('error') } #"getting articles failed."
    end
  end

  # artiles favored by other users of specified user
  def recommended_feedbacks
    @user = User.find(params[:user_id])
    @articles = Article.accessibles(current_user).feedbacks_recommended(@user).paginate(page: params[:page], per_page: Article::PER_PAGE) unless @user.blank?
    @more_link_path = more_articles_path(user_id: params[:user_id], page: @articles.next_page, articles_type: Article::List::Type::FEEDBACKS_RECOMMENDED)
    respond_to do |format|
      format.html { render 'articles_by_user' }
    end
    unless @articles.any?
      flash[:alert] = get_resource 'no_article'
    end
  end

  # artiles recommended by other users of specified user
  def recommended_articles
    @user = User.find(params[:user_id])
    @articles = @user.articles.accessibles(current_user).recommended.order_by_recommendations_count_desc.paginate(page: params[:page], per_page: Article::PER_PAGE) unless @user.blank?
    @more_link_path = more_articles_path(user_id: params[:user_id], page: @articles.next_page, articles_type: Article::List::Type::RECOMMENDED)
    respond_to do |format|
      format.html { render 'articles_by_user' }
    end
    unless @articles.any?
      flash[:alert] = get_resource 'no_article'
    end
  end

  # recommend artile list of specified user
  def recommend_articles
    @user = User.find(params[:user_id])
    @articles = @user.recommend_articles.accessibles(current_user).order_by_recommendations_count_desc.paginate(page: params[:page], per_page: Article::PER_PAGE) unless @user.blank?
    @more_link_path = more_articles_path(user_id: params[:user_id], page: @articles.next_page, articles_type: Article::List::Type::RECOMMEND)
    respond_to do |format|
      format.html { render 'articles_by_user' }
    end
    unless @articles.any?
      flash[:alert] = get_resource 'no_article'
    end
  end

  # favorite artile list of specified user
  def favorite_articles
    @user = User.find(params[:user_id])
    @articles = @user.favorite_articles.accessibles(current_user).order_by_favorites_count_desc.paginate(page: params[:page], per_page: Article::PER_PAGE) unless @user.blank?
    @more_link_path = more_articles_path(user_id: params[:user_id], page: @articles.next_page, articles_type: Article::List::Type::FAVORITES)
    respond_to do |format|
      format.html { render 'articles_by_user' }
    end
    unless @articles.any?
      flash[:alert] = get_resource 'no_article'
    end
  end

  # artile list of specified user
  def articles_by_user
    @user = User.find(params[:user_id])
    @articles = @user.articles.accessibles(current_user).paginate(page: params[:page], per_page: Article::PER_PAGE) unless @user.blank?
    @more_link_path = more_articles_path(user_id: params[:user_id], page: @articles.next_page, articles_type: Article::List::Type::USER)
    unless @articles.any?
      flash[:alert] = get_resource 'no_article'
    end
  end

  # full text search for articles and feedbacks
  def search
    @search_words = params[:search_word].split(/[#{ActiveSupport::Multibyte::Unicode.codepoints_to_pattern(ActiveSupport::Multibyte::Unicode::WHITESPACE)}]+/)
    @articles = Article.search(params[:search_word], params[:page], current_user)
    @more_link_path = more_articles_path(search_word: params[:search_word], page: @articles.next_page, articles_type: Article::List::Type::SEARCH)
    unless @articles.any?
      flash[:alert] = get_resource 'no_article'
    end
  end

  # article list of specified tag
  def articles_by_tag
    # find tag
    @tag = Tag.find(params[:tag_id])
    # if tag is found, load articles which are accessible by current uer
    unless @tag.blank?
      @articles = @tag.articles.accessibles(current_user).paginate(page: params[:page], per_page: Article::PER_PAGE)
    end
    @more_link_path = more_articles_path(search_word: params[:search_word], page: @articles.next_page, articles_type: Article::List::Type::TAG, tag_id: params[:tag_id])
    unless @articles.any?
      flash[:alert] = get_resource 'no_article'
    end
  end

  # commit or cancel recommendation of an article using ajax
  def recommend
    recommend_count = 0
    ActiveRecord::Base.transaction do
      if params[:cancel]
        # cancel recommendation
        recommend_count = ArticleRecommendation.delete(params[:article_id], current_user.id)
        logger.info "ユーザ #{current_user.id} が記事 #{params[:article_id]} に対するオススメをキャンセルしました。"
      else
        # commit reccomendation
        recommend_count = ArticleRecommendation.add(params[:article_id], current_user.id)
        logger.info "ユーザ #{current_user.id} が記事 #{params[:article_id]} に対してオススメしました。"
      end
      respond_to do |format|
        # toggle recommend button
        format.js { render locals: { article: Article.find(params[:article_id]) } }
      end
    end
  end

  # preview editing article written by wiki markup language using ajax
  def preview
    # generate html according to wiki notation type
    result = ContentFormatter.to_html(params[:content], params[:notation_type])
    respond_to do |format|
      format.html {
        # return html text
        render text: result
      }
    end
  end

  # commit or cancel favorite of article using ajax
  def favor
    favorites_count = 0
    ActiveRecord::Base.transaction do
      if params[:cancel]
        # cancel favorite
        favorites_count = Favorite.delete(params[:article_id], current_user.id)
        logger.info "ユーザ #{current_user.id} が記事 #{params[:article_id]} に対するブックマークをキャンセルしました。"
      else
        # commit favorite
        favorites_count = Favorite.add(params[:article_id], current_user.id)
        logger.info "ユーザ #{current_user.id} が記事 #{params[:article_id]} に対してブックマークしました。"
      end
      respond_to do |format|
        # toggle favorite button
        format.js { render locals: { article: Article.find(params[:article_id]) } }
      end
    end
  end

  # article list
  #   - all articles
  #   - all current user's articles
  #   - current user's private articles
  #   - current user's favorite articles
  def index
    if current_user && can?(:create, Article)
      @article = Article.new
      @article.publicity_level = current_user.role.accessibility.value
      @selectable_tags = Tag.order_by_name
    end

    get_tab_articles

    @tab_type = params[:tab_type] ? params[:tab_type] : Article::Tab::Type::ALL
    @more_link_path = more_articles_path(tab_type: @tab_type, page: @articles.next_page)
    # GET /articles/index
    unless params[:tab_type]
      @tab_type = Article::Tab::Type::ALL
      respond_to do |format|
        format.html # index.html.erb
        #format.json { render json: @articles }
      end
      return
    end
    # GET articles by tab
    if @articles.any?
      # render article list
      render file: 'articles/_list.html.erb', layout: false
      return
    end
    render text: no_article_message
  end

  # show more articles in index using ajax
  def show_more
    if params[:tab_type]
      # get articles of selected tab
      get_tab_articles
      # generate show more lind for selected tab
      @more_link_path = more_articles_path(tab_type: params[:tab_type], page: @articles.next_page)
    elsif params[:articles_type] == Article::List::Type::SEARCH
      # get rest of search result
      search
    elsif params[:articles_type] == Article::List::Type::TAG
      articles_by_tag
    elsif params[:articles_type]
      # get user's articles
      get_user_articles
      if params[:articles_type] != Article::List::Type::SEARCH
        # generate show more link for selected user's articles
        @more_link_path = more_articles_path(user_id: params[:user_id], page: @articles.next_page, articles_type: params[:articles_type])
      end
    end
  end
  # show detailed article
  def show
    @article = Article.find(params[:id])
    # load new article form for the article
    @feedback = Feedback.new
    @feedback.article_id = @article.id
    # load feedbacks for the article
    @feedbacks = Feedback.article_feedback(@article.id)

    respond_to do |format|
      format.html # show.html.erb
      #format.json { render json: @article }
    end
  end

  # article creation form
  def new
    # load selectable tags
    @selectable_tags = Tag.order_by_name
    @article = Article.new
    @article.publicity_level = current_user.role.accessibility.value

    xml = ""
    @publicities.each do |key, value|
      xml << <<-XML
      <publicity><value>#{key}</value><name>#{value}</name></publicity>
      XML
    end
    # set article's wiki notation type to user's markup lang if the user has default markup lang
    @article.notation_type = current_user.markup_lang if current_user.markup_lang
    respond_to do |format|
      format.html # new.html.erb
      format.text {
        render text: "<new_article_info>#{Tag.order_by_name.to_xml(only: [:id, :name], skip_instruct: true)}<publicities>#{xml}</publicities><authenticity_token>#{form_authenticity_token}</authenticity_token></new_article_info>"
      }
    end
  end

  # article edit form
  def edit
    # load selectable tags
    @selectable_tags = Tag.order_by_name
    @article = Article.find(params[:id])
  end

  # save new article
  #   - in index, article created using ajax
  def create
    logger.info "新規記事を登録します。"
    ActiveRecord::Base.transaction do
      # new article
      @article = Article.new(article_params)
      # set user id
      @article.user_id = current_user.id
      # set selected tags
      @article.selected_tags = "" if @article.selected_tags.blank?
      # set added tags
      @article.added_tags = "" if @article.added_tags.blank?
      # set last_updated_at
      @article.last_updated_at = Time.now
      # concatinate selected tags and addeds
      tags = @article.selected_tags << @article.added_tags

      @article.save!
      # save relations between article and tags
      Tag.save_tags!(tags, @article.id, current_user.id)

      logger.info "新規記事 #{@article.id}/#{@article.title} を登録しました。"

      # set success message
      flash[:notice] = get_resource('success')
      # show created article details
      respond_to do |format|
        format.html { redirect_to @article }
        format.text { render text: Settings.article.result_code.success }
        # ajax
        format.js { render locals: { article: @article } }
      end
    end
  rescue => e
    logger.error "新規記事の登録に失敗しました。"
    log_error e
    respond_to do |format|
      # if article creation is failed, return creation form
      @selectable_tags = Tag.order_by_name
      format.html { render action: "new" }
      format.text { render text: Settings.article.result_code.validation_error }
      # ajax
      format.js { render locals: { article: @article } }
    end
  end

  # updates edited article
  def update
    logger.info "記事を更新します。"
    ActiveRecord::Base.transaction do
      # load target article
      @article = Article.find(params[:id])
      @article.last_updated_at = Time.now
      # concatinate selected_tags and added tags
      tags = params[:article][:selected_tags].to_s << params[:article][:added_tags].to_s

      @article.update_attributes!(article_params)
      # save relations between article and tags
      Tag.save_tags!(tags, @article.id, current_user.id)

      logger.info "記事 #{@article.id}/#{@article.title} を更新しました。"

      respond_to do |format|
        format.html { redirect_to @article, notice: get_resource('success') }
      end
    end
  rescue => e
    logger.error "記事の更新に失敗しました。"
    log_error e
    # if article update is failed, return creation form
    @selectable_tags = Tag.order_by_name
    respond_to do |format|
      format.html { render action: "edit" }
    end
  end

  # deletes article
  def destroy
    @article = Article.find(params[:id])
    logger.info "記事 #{@article.id} を削除します。"
    # logical deletion
    @article.destroy

    logger.info "記事を削除しました。"

    respond_to do |format|
      format.html { redirect_to articles_url, notice: get_resource('success') }
      #format.json { head :no_content }
    end
  rescue => e
    logger.error "記事の削除に失敗しました。"
    raise e
  end

  private

  #
  # authenticate user who access via desktop application
  # if user is authenticated, @user will be set
  # otherwise @user will be nil
  #
  #def auto_login
    #@user = User.authenticate(params[:username], params[:password])
  #rescue
    #@user = nil
  #end

  #
  # determines whether request has been sent from desktop application
  # ==== Return
  # true if request has been sent from desktop application,
  # otherwise false
  #def from_desktop?
    #auto_login
    #!!@user
  #end

  #
  # render no article message
  # ==== Return
  # message html
  #
  def no_article_message
    html = <<-HTML
      <div class="alert alert-block">
        <a class="close" data-dismiss="alert">&times;</a>
        <h4 class="alert-heading">#{t('alert_title')}</h4>
        <ul><li>#{get_resource('no_article')}</li></ul>
      </div>
    HTML
    html.html_safe
  end

  # loads user's article list
  def get_user_articles
    @user = User.find(params[:user_id])
    case params[:articles_type]
    when Article::List::Type::RECOMMEND
      @articles = @user.recommend_articles.accessibles(current_user).order_by_recommendations_count_desc.paginate(page: params[:page], per_page: Article::PER_PAGE).all unless @user.blank?
    when Article::List::Type::RECOMMENDED
      @articles = @user.articles.accessibles(current_user).recommended.order_by_recommendations_count_desc.paginate(page: params[:page], per_page: Article::PER_PAGE).all unless @user.blank?
    when Article::List::Type::FAVORITES
      @articles = @user.favorite_articles.accessibles(current_user).order_by_favorites_count_desc.paginate(page: params[:page], per_page: Article::PER_PAGE).all unless @user.blank?
    when Article::List::Type::USER
      @articles = @user.articles.accessibles(current_user).paginate(page: params[:page], per_page: Article::PER_PAGE).all unless @user.blank?
    end
  end

  # loads article list according to selected tab type in index
  def get_tab_articles
    case params[:tab_type]
    when Article::Tab::Type::FAVORITES #'favorites'
      @articles = current_user.favorite_articles.paginate(page: params[:page], per_page: Article::PER_PAGE).all if current_user
    when Article::Tab::Type::MY #'my_articles'
      @articles = current_user.articles.publics.paginate(page: params[:page], per_page: Article::PER_PAGE).all if current_user
    when Article::Tab::Type::PRIVATES # 'private_articles'
      @articles = Article.privates(current_user).paginate(page: params[:page], per_page: Article::PER_PAGE).all
    when Article::Tab::Type::ALL # 'all_articles'
      @articles = Article.order_by_last_updated_at_desc.accessibles(current_user).paginate(page: params[:page], per_page: Article::PER_PAGE).all
    when Article::Tab::Type::RECENTLY_FEEDBACKED
      @articles = Article.recently_feedbacked(current_user).paginate(page: params[:page], per_page: Article::PER_PAGE).all
    when Article::Tab::Type::RECENTLY_RECOMMENDED
      @articles = Article.recently_recommended(current_user).paginate(page: params[:page], per_page: Article::PER_PAGE).all
    else # index inial display
      @articles = Article.order_by_last_updated_at_desc.accessibles(current_user).paginate(page: params[:page], per_page: Article::PER_PAGE).all
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :content, :selected_tags, :added_tags, :notation_type, :publicity_level)
  end
end
