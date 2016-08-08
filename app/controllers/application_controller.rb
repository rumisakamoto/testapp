# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :log_start, :initialize_rankings

  after_filter :log_end

  helper_method :get_resource

  # ログイン画面に遷移
  def not_authenticated
    redirect_to login_url, alert: I18n.t('please_login')
  end

  # config/locale/*.yamlからリソースを取得する
  # ==== Args
  # _resource_key_ :: リソースキー
  def get_resource(resource_key)
    I18n.t("#{controller_name}.#{action_name}.#{resource_key}")
  end

  #= エラー処理
#  rescue_from(Exception) do |exception|
#    if exception.instance_of? CanCan::AccessDenied
#      # 権限エラー
#      if current_user
#        logger.error "ユーザ #{current_user.username} が実行権限のないアクションを実行しようとしました。"
#      else
#        logger.error "未ログインユーザが実行権限のないアクションを実行しようとしました。"
#      end
#      log_error exception
#      redirect_to root_url, alert: I18n.t('permission_error')
#    else
#      unless Rails.env.development?
#        render_error(exception)
#      else
#        throw exception
#      end
#    end
#  end

  protected

  def log_start
    header = 'LOG START------------------------------------------------'
    footer = '-' * header.length
    logger.info header
    log_info
    logger.info footer
    log_current_user
  end

  def log_end
    footer = '---------------------------------------------------LOG END'
    header = '-' * footer.length
    logger.info header
    log_info
    logger.info footer
  end

  def log_info
    logger.info "controller_name: #{self.controller_name}, action_name: #{self.action_name}"
    if request
      logger.info "request_url=#{request.url}"
      logger.info "ip=#{request.remote_ip}"
    end
  end

  # ログインユーザをログに記録する
  def log_current_user
    return unless current_user
    header = '----------'
    footer = '-' * header.length
    header << ' Start: Login User Info'
    footer << ' End:   Login User Info'
    logger.info header
    logger.info "id = #{current_user.id}, username = #{current_user.username}, role = #{current_user.role.id}/#{current_user.role.name}"
    if controller_name == 'sessions' || controller_name == 'articles'
      logger.debug "session dump: #{YAML::dump(session.inspect)}"
    end
    logger.info footer
  end

  #= 500エラー時ログ
  def render_error(ex)
    header = '**********'
    footer = '*' * header.length
    header << ' Start: Unexpected Error Log'
    footer << ' End:  Unexpected Error Log'
    logger.error header
    log_error(ex)
    logger.error footer
    # エラー通知メールを送信
    begin
      AlertMailer.alert_mail(header, request, ex, current_user, footer).deliver
    rescue => mail_ex
      logger.error "Front system alert mail cannot be sent."
      log_error mail_ex
    end

    # Internal server error 500を表示
    # TODO エラー画面
    redirect_to root_url, alert: I18n.t('unexpected_error')
  end

  # 例外ログ
  def log_error e
    logger.error "========================================================="
    logger.error e.class
    logger.error e.message
    logger.error e.backtrace.join("\n")
    logger.error "Parameters: #{params.inspect}"
    logger.error "Session: #{session.inspect}"
    logger.error "========================================================="
  end

  private

  # ランキングを生成する
  def initialize_rankings
    @tags_ranking = Tag.well_used_tags.paginate(page: 1, per_page: Toppage::Ranking::PerPage::TAGS)
    @article_users_ranking = User.heavy_users.paginate(page: 1, per_page: Toppage::Ranking::PerPage::USERS)
    @recommened_articles_ranking = Article.most_recommended(current_user).paginate(page: 1, per_page: Toppage::Ranking::PerPage::ARTICLES)
    @favorite_articles_ranking = Article.most_favorited(current_user).paginate(page: 1, per_page: Toppage::Ranking::PerPage::ARTICLES)
    @feedback_users_ranking = User.heavy_feedback_users.paginate(page: 1, per_page: Toppage::Ranking::PerPage::USERS)
  end
end
