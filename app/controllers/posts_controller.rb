class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session   
  skip_before_filter :verify_authenticity_token, :only => [:update, :posts_nearby]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
    respond_to do |format|
      format.html
      format.json { render :json => @posts.to_json(:include => { :assets => {:only => [:file_file_name, :file_content_type],:methods => :file_url }})}
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render :json => @post.to_json(:include => { :assets => {:only => [:file_file_name, :file_content_type],:methods => :file_url }})}
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
    5.times { @post.assets.build }
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
    5.times { @post.assets.build }
  end

  # POST /posts
  # POST /posts.json
  def create
    begin
      @post = Post.new(post_params)
      if @post.save
        unless params[:post][:category].nil? || params[:post][:category].empty?
          params[:post][:category].each do |category_param|
            category = Category.where(name: category_param).first
            unless category.nil?
              type = PostType.new(post_id: @post.id, category_id: category.id)
              type.save!
            end
          end
        end
        if params[:post][:images]
          params[:post][:images].each do |image|
            asset = Asset.find_by_id(image.to_i)
            @post.assets << asset
            @post.save!
          end
        end
        render json: @post, status: :ok
      else
        render json: @post.errors, status: :unprocessable_entity 
      end
    rescue
      render json: @post.errors, status: :unprocessable_entity 
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    begin
      @post.update(post_params)
      if params[:assets_images]
        params[:assets_images].each { |image|
          # Crea la imagen a partir del data
          data = StringIO.new(Base64.decode64(image[:data]))
          data.class.class_eval { attr_accessor :original_filename, :content_type }
          data.original_filename = image[:filename]
          data.content_type = image[:content_type]
          @post.assets.create(file: data)
        }
      end
      render json: "Post was successfully updated.", status: :ok
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    begin
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      render json: "Post was successfully destroyed.", status: :unprocessable_entity
    end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  #POST /posts_by_user/:user_id
  def posts_by_user
    if params[:user_id]
      posts = Post.where(user_id: params[:user_id])
      if posts.empty?
        render json: "no posts", status: :unprocessable_entity
      else
        render json: posts.to_json(:methods => :first_image), status: :ok
      end
      
    else
      render json: "error", status: :unprocessable_entity
    end
  end

   #POST /posts_nearby
  def posts_nearby
    begin
      if params[:distance] && params[:latitude] && params[:longitude]
        posts = Post.near([params[:latitude].to_f, params[:longitude].to_f], params[:distance].to_i, :units => :km)
        if posts.empty?
          render json: "empty", status: :unprocessable_entity
        else
          render json: posts, status: :ok
        end
      else
        render json: "error", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

   #GET /popular_posts/:n
  def popular_posts
    begin
      votes = Favorite.group(:post_id).count
      if votes.empty?
        render json: "no hay votos", status: :unprocessable_entity
      else
        posts_to_return = []
        popular_posts = []
        params[:n] ? n=params[:n].to_i : n=10
        votes.sort_by{ |k,v| v}.reverse.first(n).each{ |id,votes| popular_posts<<id}
        popular_posts.each do |post_id|
          posts_to_return << Post.find_by_id(post_id)
        end
        render json: posts_to_return.to_json(:include => { :assets => {:only => [:file_file_name, :file_content_type],:methods => :file_url }}), status: :ok
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

   #GET /followers_posts/:user_id/:n
  def followers_posts
    begin
      if params[:user_id]
        params[:n] ? n=params[:n].to_i : n=10
        order_followers = []
        followers = User.find_by_id(params[:user_id]).followers.pluck(:id)
        unless followers.nil? || followers.empty?
          popular_followers = Relationship.where(followed_id: followers).group(:followed_id).count
          popular_followers.sort_by{ |k,v| v}.reverse.first(n).each{ |id,followers| order_followers<<id}
          posts_to_return = []
          order_followers.each do |author|
            posts_to_return << Post.where(user_id: author).order("created_at DESC").limit(5)
          end
          render json: posts_to_return, status: :ok
        else
          render json: "no followers", status: :unprocessable_entity
        end
      else
        render json: "wrong params", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  #GET /n_posts/:n
  def n_posts
    begin
      if params[:n]
        n = params[:n].to_i
        posts = Post.order("posts.created_at DESC").page(n).per(10)
        if posts.empty?
          render json: "empty", status: :unprocessable_entity
        else
          render json: posts, status: :ok
        end
      else
        render json: "error", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  #POST /favorite
  def favorite
    begin
      if params[:user_id] && params[:post_id]
        user = User.find(params[:user_id].to_i)
        post = Post.find(params[:post_id].to_i)
        favorite = Favorite.where(user_id: params[:user_id].to_i, post_id: params[:post_id].to_i)
        if user && post && favorite.empty?
          favorite = Favorite.new({user_id: user.id, post_id: post.id})
          favorite.save!
          render json: "favorite successfully added", status: :ok
        else
          render json: "user/post not exist / favorite already exist", status: :unprocessable_entity
        end
      else
        render json: "error", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  #DELETE /favorite
  def undo_favorite
    begin
      if params[:user_id] && params[:post_id]
        user = User.find(params[:user_id].to_i)
        post = Post.find(params[:post_id].to_i)
        favorite = Favorite.where(user_id: params[:user_id].to_i, post_id: params[:post_id].to_i)
        if user && post && !favorite.empty?
          favorite.first.destroy!
          render json: "favorite successfully deleted", status: :ok
        else
          render json: "user/post not exist / favorite not exist", status: :unprocessable_entity
        end
      else
        render json: "wrong params", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  # POST /upload_assets
  def upload_assets
    begin
      if params[:assets_images]
        # Crea la imagen a partir del data
        data = StringIO.new(Base64.decode64(params[:assets_images][:data]))
        data.class.class_eval { attr_accessor :original_filename, :content_type }
        data.original_filename = params[:assets_images][:filename]
        data.content_type = params[:assets_images][:content_type]
        asset = Asset.new(file: data)
        asset.save!
        render json: asset.to_json(only: :id) , status: :ok 
      else
        render json: "no image attached", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :user_id, :description, :images, :date, :location, :category, :latitude, :longitude, assets_attributes: [:id, :post_id, :file])#, assets_images: [:data, :filename, :content_type]) 
      #params.require(:post).permit!
    end
end
