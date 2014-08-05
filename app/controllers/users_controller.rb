class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session   

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
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

    respond_to do |format|
      # Controla si existe el usuario, si existe retorna ok, sino lo crea
      auxUser = User.where(email: user_params[:email]).first
      if auxUser
        #format.html { redirect_to auxUser, notice: 'User in.' }
        format.json { head :ok }
      else
        @user = User.new(user_params)
        user.login_type = "facebook"
        if params[:avatar64]
          data = StringIO.new(Base64.decode64(params[:avatar64][:data]))
          data.class.class_eval { attr_accessor :original_filename, :content_type }
          data.original_filename = params[:avatar64][:filename]
          data.content_type = params[:avatar64][:content_type] 
          @user.avatar = data
        end

        if @user.save
          #format.html { redirect_to @user, notice: 'User was successfully created.' }
          format.json { head :ok }
        else
          #format.html { render :new }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
        
      end
    end
  end

    # POST /login_twitter
  def create_twitter
    @user = User.new(user_params)
    user.login_type = "twitter"
    if params[:avatar64]
      data = StringIO.new(Base64.decode64(params[:avatar64][:data]))
      data.class.class_eval { attr_accessor :original_filename, :content_type }
      data.original_filename = params[:avatar64][:filename]
      data.content_type = params[:avatar64][:content_type] 
      @user.avatar = data
    end
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { head :ok}
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

    # POST /login_common
  def create_common
    @user = User.new(user_params)
    user.login_type = "common"
    if params[:avatar64]
      data = StringIO.new(Base64.decode64(params[:avatar64][:data]))
      data.class.class_eval { attr_accessor :original_filename, :content_type }
      data.original_filename = params[:avatar64][:filename]
      data.content_type = params[:avatar64][:content_type] 
      @user.avatar = data
    end
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { head :ok }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def login_common
    respond_to do |format|
      if params[:username] && params[:password]
        user = User.where(username: params[:username], password: params[:password]).first
        if user
          format.json { head :ok }
        end
      end
      format.json { render json: "usuario o contrasena incorrecta", status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
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
