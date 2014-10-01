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

      respond_to do |format|
        if @post.save
          if params[:assets_attributes]
            params[:assets_attributes].each { |key, photo|
              @post.assets.create(file: photo)
            }
          else
            # Si no recibe en el assets_atributes controlo si viene en base64
            # Thread.new do
            #   puts "I'm in a thread!"
            # end
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
          end
          format.html { redirect_to @post, notice: 'Post was successfully created.' }
          format.json { render :show, status: :created, location: @post }
        else
          format.html { render @post.errors }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    rescue
      format.html { render @post.errors }
      format.json { render json: @post.errors, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #POST /posts_by_user/:user_id
  def posts_by_user
    if params[:user_id]
      posts = Post.where(user_id: params[:user_id])
      if posts.empty?
        render json: "no posts", status: :unprocessable_entity
      else
        render json: posts, status: :ok
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

  #POST /favorite
  def undo_favorite
    begin
      if params[:user_id] && params[:post_id]
        user = User.find(params[:user_id].to_i)
        post = Post.find(params[:post_id].to_i)
        favorite = Favorite.where(user_id: params[:user_id].to_i, post_id: params[:post_id].to_i)
        if user && post && !favorite.empty?
          favorite.destroy!
          render json: "favorite successfully deleted", status: :ok
        else
          render json: "user/post not exist / favorite not exist", status: :unprocessable_entity
        end
      else
        render json: "error", status: :unprocessable_entity
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
      params.require(:post).permit(:title, :user_id, :description, :image, :date, :location, :category, :latitude, :longitude, assets_attributes: [:id, :post_id, :file])#, assets_images: [:data, :filename, :content_type]) 
      #params.require(:post).permit!
    end
end
