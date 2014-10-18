class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session   
  skip_before_filter :verify_authenticity_token

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    if @user
      if @user.login_type == "facebook" || @user.login_type == "twitter"
        render :json => @user.to_json(:except => [:password, :created_at, :updated_at, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at ] , include: { favorites_posts: { only: [:id, :title], include: { assets: { only: :id, methods: :file_url}}} } , methods: [:followers_quantity , :followed_quantity])
      else
        render :json => @user.to_json(:except => [:password, :created_at, :updated_at, :url_avatar], include: { favorites_posts: { only: [:id, :title], include: { assets: { only: :id, methods: :file_url}}  }} , methods: [:followers_quantity , :followed_quantity, :file_url ] )
      end
    else
      render json: "No existe el usuario", status: :unprocessable_entity
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

    # POST /login_facebook
  def create_facebook
    begin
      # Controla si existe el usuario, si existe retorna ok, sino lo crea
      @user = User.where(email: user_params[:email]).first
      if @user
        # Retorna el usuario
        render :json => @user.to_json(:except => [:password, :created_at, :updated_at, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :url_avatar ] , methods: :file_url)
      else
        @user = User.new(user_params)
        @user.login_type = "facebook"
        if params[:avatar]
          @user.url_avatar = params[:avatar]
        end
        if @user.save
        render :json => @user.to_json(:except => [:password, :created_at, :updated_at, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :url_avatar ] , methods: :file_url)
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end
    rescue

    end
  end

    # POST /login_twitter
  def create_twitter
    @user = User.where(email: user_params[:email]).first
    if @user
      # Retorna el usuario
        render :json => @user.to_json(:except => [:password, :created_at, :updated_at, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :url_avatar ] , methods: :file_url)
    else
      @user = User.new(user_params)
      @user.login_type = "twitter"
      if params[:avatar]
        @user.url_avatar = params[:avatar]
      end
      if @user.save
        render :json => @user.to_json(:except => [:password, :created_at, :updated_at, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :url_avatar ] , methods: :file_url)
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end
  end

    # POST /register_common
  def create_common
    @user = User.new(user_params)
    @user.login_type = "common"
    if params[:avatar64]
      data = StringIO.new(Base64.decode64(params[:avatar64][:data]))
      data.class.class_eval { attr_accessor :original_filename, :content_type }
      data.original_filename = params[:avatar64][:filename]
      data.content_type = params[:avatar64][:content_type] 
      @user.avatar = data
    end
    if @user.save
        render :json => @user.to_json(:except => [:password, :created_at, :updated_at, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :url_avatar ] , methods: :file_url)
    else
      render json: @user.errors, status: :unprocessable_entity 
    end 
  end

  # POST /login_common
  def login_common
    if params[:email] && params[:password]
      @user = User.where(email: params[:email], password: params[:password]).first
      if @user
        render :json => @user.to_json(:except => [:password, :created_at, :updated_at, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :url_avatar ] , methods: :file_url)
      else
        render json: "usuario o contrasena incorrecta", status: :unprocessable_entity 
      end
    else
      render json: "usuario o contrasena incorrecta", status: :unprocessable_entity 
    end
  end

  #POST /follow_user
  def follow_user
    begin
      if params[:follower] && params[:followed]
        follower = User.find(params[:follower].to_i)
        followed = User.find(params[:followed].to_i)
        if follower.nil? || followed.nil?
          render json: "empty", status: :unprocessable_entity
        else
          follower.follow!(followed)
          render json: "followed added with success", status: :ok
        end
      else
        render json: "error", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  #DELETE /follow_user
  def unfollow_user
    begin
      if params[:follower] && params[:followed]
        follower = User.find(params[:follower].to_i)
        followed = User.find(params[:followed].to_i)
        if follower.nil? || followed.nil? || follower.following?(followed).nil?
          render json: "they are not followers", status: :unprocessable_entity
        else
          follower.unfollow!(followed)
          render json: "followed deleted with success", status: :ok
        end
      else
        render json: "wrong params", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  #GET /favorites/:id
  def favorites
    begin
      if params[:id]
        user = User.find(params[:id].to_i)
        posts = user.favorites_posts
        if posts.empty?
          render json: "no favorites for that user", status: :unprocessable_entity
        else
          render json: posts, status: :ok
        end
      else
        render json: "wrong params", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  #GET /followers/:id
  def followers
    begin
      if params[:id]
        user = User.find(params[:id].to_i)
        followers = user.followers
        if followers.empty?
          render json: "user not has any follower", status: :unprocessable_entity
        else
          render json: followers.to_json(:except => [:password, :created_at, :updated_at, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at ] , methods: :file_url), status: :ok
        end
      else
        render json: "wrong params", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  #GET /followed/:id
  def followed
    begin
      if params[:id]
        user = User.find(params[:id].to_i)
        followed_users = user.followed_users
        if followed_users.empty?
          render json: "user isnt following any user", status: :unprocessable_entity
        else
          render json: followed_users.to_json(:except => [:password, :created_at, :updated_at, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at ] , methods: :file_url), status: :ok
        end
      else
        render json: "wrong params", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if params[:avatar64]
        data = StringIO.new(Base64.decode64(params[:avatar64][:data]))
        data.class.class_eval { attr_accessor :original_filename, :content_type }
        data.original_filename = params[:avatar64][:filename]
        data.content_type = params[:avatar64][:content_type] 
        @user.avatar = data
      end
      if @user.update(user_params)
        format.html { render json: @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :email, :first_name, :last_name, :facebook_id, :twitter_id, :city, :country, :password, :avatar)
    end
end
