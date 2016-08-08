# -*- encoding : utf-8 -*-
class UsersController < ApplicationController

  before_filter :require_login, only: [:index, :edit, :update]

  load_and_authorize_resource

  def new
    @user = User.new
  end

  def create
    logger.info "新規ユーザを登録します。"
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        logger.info "新規ユーザ #{@user.id}/#{@user.username} を登録しました。"
        format.html { redirect_to root_url, notice: get_resource('signedup') }
      else
        logger.error "新規ユーザの登録に失敗しました。"
        format.html { render :new }
      end
    end
  end

  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def index
    @users = User.paginate(page: params[:page], per_page: User::PER_PAGE)
    respond_to do |format|
      format.html
    end
  end

  def destroy
    @user = User.find(params[:id])
    logger.info "ユーザ #{@user.id}/#{@user.username} を削除します。"

    @user.delete!

    respond_to do |format|
      format.html { redirect_to action: :index }
    end
    logger.info "ユーザ #{@user.id}/#{@user.username} を削除しました。"
  end

  def edit
    @user = User.find(params[:id])
    set_password_requirements
    respond_to do |format|
      format.html
    end
  end

  def update
    @user = User.find(params[:id])
    logger.info "ユーザ #{@user.id}/#{@user.username} の情報を更新します。"
    set_password_requirements
    # get admin username when admin changed other user info to authenticate admin user
    @user.admin_username = current_user.username if @user.require_admin_password
    # current user's password is not required
    @user.require_password = false

    # if both password and password_confirmation are not entered, they are not to be validated
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete :password
      params[:user].delete :password_confirmation
      logger.debug params[:user].inspect
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        logger.info "ユーザ情報を更新しました。"
        format.html { render action: :show }
      else
        logger.error "ユーザ情報の更新に失敗しました。"
        format.html { render action: :edit }
      end
    end
  end

  private

  def set_password_requirements
    # only admin has permission for users#create

    # user password is not required for admin user or when admin changes his info
    @user.require_password = cannot?(:create, User) || current_user.id == @user.id
    logger.debug "current user has to enter own password" if @user.require_password
    # require admin password when admin changes other user information
    @user.require_admin_password = can?(:create, User) && current_user.id != @user.id
    logger.debug "current user has to enter own admin password" if @user.require_admin_password
  end
end
