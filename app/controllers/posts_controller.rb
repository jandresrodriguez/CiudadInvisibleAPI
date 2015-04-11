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
      format.json { render :json => @posts.to_json(:include => { :assets => {:only => [:file_file_name, :file_content_type],:methods => :file_url }, :categories => {:only => [:name]}} , :methods => [:author, :author_avatar, :favorites_quantity, :comments, :comments_quantity])}
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render :json => @post.to_json(:include => { :assets => {:only => [:file_file_name, :file_content_type],:methods => :file_url }, :categories => {:only => [:name]}}, :methods => [:author, :favorites_quantity, :comments, :comments_quantity])}
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
            if asset
              @post.assets << asset
            end
          end
        end
        @post.save!
        render json: @post.to_json(:include => { :categories => { :only => [:name]}}), status: :ok
      else
        render json: @post.errors, status: :unprocessable_entity 
      end
    rescue
      render json: @post.errors, status: :unprocessable_entity 
    end
  end

  # POST /posts_mobile
  # POST /posts.json
  def create_mobile
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
        render json: @post
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
        render json: "no posts", status: :ok
      else
        render json: posts.to_json(:include => { :assets => {:only => [:file_file_name, :file_content_type],:methods => :file_url }, :categories => {:only => [:name]}} , :methods => [:author, :author_avatar, :favorites_quantity, :comments, :comments_quantity, :first_image]), status: :ok
      end
      
    else
      render json: "error", status: :unprocessable_entity
    end
  end

   #POST /posts_nearby
  def posts_nearby
    begin
      if params[:distance] && params[:latitude] && params[:longitude]
        posts = posts_near(params[:latitude].to_f, params[:longitude].to_f, params[:distance].to_i)
        if posts.empty?
          render json: "empty", status: :ok
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
        render json: "no hay votos", status: :ok
      else
        posts_to_return = get_popular_posts(votes, params[:n])
        render json: posts_to_return.to_json(:include => { :assets => {:only => [:file_file_name, :file_content_type],:methods => :file_url }}, :methods => [:favorites_quantity, :author_avatar, :comments_quantity]), status: :ok
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

   #GET /followed_posts/:user_id/:n
  def followed_posts
    begin
      if params[:user_id]
        params[:n] ? n=params[:n].to_i : n=10
        followed_users = User.find_by_id(params[:user_id]).followed_users.pluck(:id)
        unless followed_users.nil? || followed_users.empty?
          posts_to_return = get_followed_posts(followed_users,n)
          render json: posts_to_return.to_json(:methods => [:first_image, :favorites_quantity, :comments_quantity]), status: :ok
        else
          render json: "no followers", status: :ok
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
        posts = last_n_posts(n)
        if posts.empty?
          render json: "empty", status: :ok
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
          notification = Notification.new(creator_id: user.id, receiver_id: post.user.id, post_id: post.id, notification_type: "Favorite")
          payload = notification.set_notification_data(nil, nil, params[:post_id])
          Notifier.send_notification(notification, payload)
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

  # POST /assets_mobile/:id
  def assets_mobile
    begin
      @post = Post.find(params[:id].to_i)
      # Asigna los assets
      if params[:assets_attributes]
        params[:assets_attributes].each { |key, photo|
          @post.assets.create(file: photo)
        }
      else
        if params[:assets_images]
          params[:assets_images].each { |image|
            # Crea la imagen a partir del data
            data = StringIO.new(Base64.decode64(image[:data]))
            data.class.class_eval { attr_accessor :original_filename, :content_type }
            data.original_filename = image[:filename]
            data.content_type = image[:content_type]
            
            @post.assets.create(file: data, rotation: true)

          }
        end
      end
      render json: "assets assigned successfully", status: :ok 

    rescue
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  #POST /preferences_posts
  def preferences_posts
    begin
      preferences_posts = []
      if params[:latitude] && params[:longitude] 
        #obtener mas cercanos
        preferences_posts = preferences_posts + posts_near(params[:latitude].to_f,params[:longitude].to_f,5)
      end
      if params[:user_id] 
        #obtener posts de tus seguidores
        followers = User.find_by_id(params[:user_id]).followers.pluck(:id)
        unless followers.nil? || followers.empty?
            preferences_posts = preferences_posts + followers_posts(followers,n)
        end
      end
      #obtener mas populares
      votes = Favorite.group(:post_id).count
      unless votes.empty?
        preferences_posts = preferences_posts + popular_posts(votes)
      end
      #obtener ultimos
      preferences_posts = preferences_posts + last_n_posts(10)
      #mezclarlos randomicamente
      if params[:quantity] && params[:quantity] > preferences_posts.size
        preferences_posts.shuffle.take(params[:quantity])
      else
        preferences_posts.shuffle
      end
      #devolver
      if preferences_posts.empty?
        render json: "no hay posts suficientes", status: :ok
      else
        render json: preferences_posts.to_json(:include => { :assets => {:only => [:file_file_name, :file_content_type],:methods => :file_url }} , :methods => [:author, :author_avatar, :favorites_quantity, :comments, :comments_quantity, :first_image]), status: :ok
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  #POST /random_tour
  def random_tour
    begin
      if params[:latitude] && params[:longitude] && params[:user_id]
        tour = Tour.new
        tour.user_id = params[:user_id]
        tour.save!
        nearby_posts = Post.near([params[:latitude], params[:longitude]], 2, :units => :km).first(30)
        unless nearby_posts.empty?
          posts_to_see_unordered = nearby_posts.sample(5)
          start_point = closest(params[:latitude], params[:longitude], posts_to_see_unordered)
          posts_to_see_unordered.delete(start_point)
          i=1
          while posts_to_see_unordered.size > 0
            if start_point
              posts_to_see_unordered.delete(start_point)
              closest = closest(start_point.latitude, start_point.longitude, posts_to_see_unordered)
              place_tour = PartOfTour.create(post_id: start_point.id, tour_id: tour.id, tour_order: i)
              i = i + 1
              start_point = closest
            end
          end
          render json: tour.to_json(include: { part_of_tours: { include: { post: { include: { assets: { only: [:file_file_name, :file_content_type], methods: :file_url }} , :methods => [:author, :author_avatar, :favorites_quantity, :comments, :comments_quantity, :first_image] }}}}), status: :ok
        else
          render json: "Not nearby posts", status: :ok
        end
      else
        render json: "wrong params", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  #POST /comment
  def comment
    begin
      if params[:post_id] && params[:user_id] && params[:comment]
        comment = Comment.new(post_id: params[:post_id], user_id: params[:user_id], text: params[:comment] )
        comment.save!
        notification = Notification.new(creator_id: comment.user.id, receiver_id: comment.post.user.id, post_id: comment.post.id, notification_type: "Comment")
        payload = notification.set_notification_data(nil, nil, params[:post_id])
        Notifier.send_notification(notification, payload)
        render json: "comment created successfully", status: :ok
      else
        render json: "wrong params", status: :unprocessable_entity
      end
    rescue 
      render json: "error", status: :unprocessable_entity
    end
  end

  #POST /search/:search_text
  def search_post
    begin
      if params[:search_text]
        posts = Post.where('title LIKE ?', "%#{params[:search_text]}%")
        render :json => posts.to_json(:include => { :assets => {:only => [:file_file_name, :file_content_type],:methods => :file_url }}, :methods => [:author, :favorites_quantity, :comments])
      else
        render json: "wrong params", status: :unprocessable_entity
      end
    rescue 
      render json: "error", status: :unprocessable_entity
    end
  end

  # GET /draft_by_user/:id
  def draft_by_user
    begin
      @user = User.find(params[:id])
      if @user
        render json: @user.posts.drafts.to_json(:include => { :assets => {:only => [:file_file_name, :file_content_type],:methods => :file_url }}, :methods => [:author, :favorites_quantity, :comments])
      else
        render json: @post.errors, status: :unprocessable_entity 
       end
    rescue
      render json: @post.errors, status: :unprocessable_entity 
    end
  end

  #-----------------------------------------------------------------------------------------------
  # API ENDPOINTS - PUBLIC
  #-----------------------------------------------------------------------------------------------
  
  #GET /v1/places/
  def public_near
    begin
      if params[:distance] && params[:latitude] && params[:longitude]
        params[:n] ? n=params[:n].to_i : n=50
        posts = posts_near(params[:latitude].to_f, params[:longitude].to_f, params[:distance].to_i)
        
        json_object = JSON.parse(posts.limit(n).to_json(only: [:id, :title, :description, :date, :latitude, :longitude], include: { assets: {only: [],methods: :file_url }}, methods: :author)) 
        render json: JSON.pretty_generate(json_object), status: :ok
      else
        render json: "Wrong params", status: :unprocessable_entity
      end
    rescue
      render json: "Unexpected error", status: :unprocessable_entity
    end
  end
  
  #GET /v1/popular_places/
  def public_popular
    begin
      params[:n] ? n=params[:n].to_i : n=50
      votes = Favorite.group(:post_id).count
      posts = get_popular_posts(votes, n)

      json_object = JSON.parse(posts.to_json(only: [:id, :title, :description, :date, :latitude, :longitude], include: { assets: {only: [],methods: :file_url }}, methods: :author)) 
      render json: JSON.pretty_generate(json_object), status: :ok
    rescue
      render json: "Unexpected error", status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :user_id, :description, :images, :date, :location, :category, :latitude, :longitude, assets_attributes: [:id, :post_id, :file])
    end

    def posts_near(latitude,longitude,distance)
      posts = Post.near([latitude, longitude], distance, :units => :km)
      posts
    end

    def get_popular_posts(votes, n)
      posts_to_return = []
      popular_posts = []
      n ? n=n.to_i : n=10
      votes.sort_by{ |k,v| v}.reverse.first(n).each{ |id,votes| popular_posts<<id}
      popular_posts.each do |post_id|
        posts_to_return << Post.find_by_id(post_id)
      end
      posts_to_return
    end

    def get_followed_posts(followed,n)
      order_followed = []
      popular_followed = Relationship.where(followed_id: followed).group(:followed_id).count
      popular_followed.sort_by{ |k,v| v}.reverse.first(10).each{ |id,followed| order_followed<<id}
      posts_to_return = Post.where(user_id: order_followed).order("created_at DESC").limit(n)
    end

    def last_n_posts(n)
      posts = Post.order("posts.created_at DESC").page(n).per(10)
      posts
    end

    def closest(latitude_start,longitude_start, places)
      min_distance = 100000
      near_place = nil
      places.try(:each) do |place|
        distance = place.distance_from([latitude_start,longitude_start])
        if distance < min_distance
          min_distance = distance
          near_place = place
        end
      end
      near_place
    end
end
