# -*- encoding : utf-8 -*-
class FeedbacksController < ApplicationController

  before_filter :require_login, only: [:new, :create, :edit, :update, :destroy, :preview, :recommend]

  load_and_authorize_resource

  # AJAXでオススメボタンをクリックしたときのアクション
  def recommend
    recommend_count = 0
    ActiveRecord::Base.transaction do
      if params[:cancel]
        recommend_count = FeedbackRecommendation.delete(params[:feedback_id], current_user.id)
        logger.info "ユーザ #{current_user.id} がフィードバック #{params[:feedback_id]} に対するオススメをキャンセルしました。"
      else
        recommend_count = FeedbackRecommendation.add(params[:feedback_id], current_user.id)
        logger.info "ユーザ #{current_user.id} がフィードバック #{params[:feedback_id]} に対してオススメしました。"
      end
    end
    respond_to do |format|
      format.js { render locals: { feedback: Feedback.find(params[:feedback_id]) } }
    end
  end

  # マークアッププレビュー
  def preview
    result = ContentFormatter.to_html(params[:content], params[:notation_type])
    respond_to do |format|
      format.html { render text: result }
    end
  end

  # GET /feedbacks/new
  # GET /feedbacks/new.json
  def new
    @feedback = Feedback.new
    @feedback.article_id = params[:article_id]
    @article = @feedback.article

    respond_to do |format|
      format.html # new.html.erb
      #format.json { render json: @feedback }
    end
  end

  # GET /feedbacks/1/edit
  def edit
    @feedback = Feedback.find(params[:id])
    @article = @feedback.article
  end

  # POST /feedbacks
  # POST /feedbacks.json
  def create
    logger.info "記事 #{params[:article_id]} に対するフィードバックを新規登録します。"
    ActiveRecord::Base.transaction do
      @feedback = Feedback.new(feedback_params)
      @feedback.article_id = params[:article_id]
      @feedback.user_id = current_user.id
      @feedback.last_updated_at = Time.now

      @feedback.save!
      logger.info "記事 #{params[:article_id]} に対するフィードバックを新規登録しました。"
    end
    respond_to do |format|
        format.html {
          #redirect_to controller: :articles, action: :show, id: params[:article_id]
          redirect_to article_path(@feedback.article_id), notice: get_resource('success')
        }
    end
  rescue => e
    @article = Article.find(params[:article_id])
    logger.error "フィードバックの登録に失敗しました。"
    log_error e
    respond_to do |format|
      format.html { render :new }
    end
  end

  # PUT /feedbacks/1
  # PUT /feedbacks/1.json
  def update
    @feedback = Feedback.find(params[:id])
    logger.info "フィードバック #{@feedback.id} を更新します。"
    @feedback.last_updated_at = Time.now
    ActiveRecord::Base.transaction do
      respond_to do |format|
        if @feedback.update_attributes(feedback_params)
          logger.info "フィードバック #{@feedback.id} を更新しました。"
          format.html { redirect_to article_path(@feedback.article_id), notice: get_resource('success') }
          #format.json { head :no_content }
        else
          logger.info "フィードバックの更新に失敗しました。"
          format.html { render action: "edit" }
          #format.json { render json: @feedback.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.json
  def destroy
    @feedback = Feedback.find(params[:id])
    logger.info "フィードバック #{@feedback.id} を削除します。"
    @feedback.destroy
    logger.info "フィードバックを削除しました。"
    respond_to do |format|
      format.html { redirect_to article_path(@feedback.article_id), notice: get_resource('success') }
      #format.json { head :no_content }
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:article_id, :content, :notation_type, :feedback_type)
  end
end

