# -*- encoding : utf-8 -*-
class SessionsController < ApplicationController

  # ログイン
  def new
    @login_form = LoginForm.new
    respond_to do |form|
      form.html
      form.text { render text: form_authenticity_token }
    end
  end

  # ログイン実行
  def create
    @login_form = LoginForm.new(params[:login_form])

    @login_form.validate!

    if @login_form.errors.any?
      respond_to do |format|
        format.html { render action: :new }
        format.text { render text: Settings.authentication.result_code.validation_error }
      end
      return
    end

    if !@login_form.username.blank? &&
       !@login_form.password.blank? &&
       !User.can_login?(@login_form.username)
      logger.error "ユーザ #{@login_form.username} は無効なユーザです。"
      flash.now.alert = get_resource('inactive')
      respond_to do |format|
        format.html { render :new }
        format.text { render text: Settings.authentication.result_code.inactive }
        return
      end
    end

    # ログイン実行
    user = login(@login_form.username, @login_form.password, @login_form.remember_me)

    # ログイン実行結果
    msg = !!user ? Settings.authentication.result_code.success : Settings.authentication.result_code.invalid

    respond_to do |format|
      if user
        logger.info "ユーザ #{@login_form.username} がログインしました。"
        # ログイン成功
        format.html { redirect_back_or_to root_url, notice: get_resource('loggedin') }
        format.text { render text: msg }
      else
        logger.error "ユーザ #{@login_form.username} がログインできませんでした。"
        # ログイン失敗
        flash.now.alert = get_resource('invalid')
        format.html { render :new }
        format.text { render text: msg }
      end
    end
  end

  # ログアウト
  def destroy
    logout
    respond_to do |format|
      format.html { redirect_to root_url, notice: get_resource('loggedout') }#"Logged out!"
      format.text { render text: Settings.authentication.result_code.logout }
    end
  end
end
