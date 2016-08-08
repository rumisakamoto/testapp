class TagsController < ApplicationController

  # require login before each action
  before_filter :require_login
  # each action can be accessed only by admin
  load_and_authorize_resource

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.order_by_name.paginate(page: params[:page], per_page: Tag::PER_PAGE)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  # GET /tags/new
  # GET /tags/new.json
  def new
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tag }
    end
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.json
  def create
    logger.info "タグ #{params[:tag]} を新規登録します。"
    @tag = Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        logger.info "タグ #{params[:tag]} を新規登録しました。"
        format.html { redirect_to tags_url, notice: get_resource('success') }
        format.json { render json: @tag, status: :created, location: @tag }
      else
        logger.error "タグ #{params[:tag]} の新規登録に失敗しました。"
        format.html { render action: "new" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.json
  def update
    @tag = Tag.find(params[:id])

    logger.info "タグ #{@tag.id} を更新します。"

    respond_to do |format|
      if @tag.update_attributes(tag_params)
        logger.info "タグ #{@tag.id} を #{params[:tag]} に更新しました。"
        format.html { redirect_to tags_url, notice: get_resource('success') }
        format.json { head :no_content }
      else
        logger.error "タグの更新に失敗しました。"
        format.html { render action: "edit" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag = Tag.find(params[:id])
    logger.info "タグ #{@tag.id} を削除します。"
    result = @tag.destroy
    if result
      logger.info "タグ #{@tag.id} を削除しました。"
      msg = get_resource 'success'
    else
      logger.error "タグ #{@tag.id} を削除できませんでした。"
      msg = get_resource 'error'
    end

    respond_to do |format|
      format.html { redirect_to tags_url, notice: msg } if result
      format.html { redirect_to tags_url, alert: msg } unless result
      format.json { head :no_content }
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :icon_url)
  end
end

