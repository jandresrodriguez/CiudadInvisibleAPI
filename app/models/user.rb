class User < ActiveRecord::Base

  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed

  has_many :reverse_relationships, foreign_key: "followed_id", class_name:  "Relationship", dependent: :destroy
  has_many :followers, through: :reverse_relationships

  has_many :favorites
  has_many :favorites_posts, through: :favorites, source: :post
	
	has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
	validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

	validates :username, presence: true
	validates :first_name, presence: true
	validates :last_name, presence: true
	validates :email, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create }

	def file_url
    # Concatena la url del host mas la de la imagen
    unless ActionController::Base.asset_host.nil?
      ActionController::Base.asset_host + avatar.url
    else
      avatar.url 
    end
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end

  def followers_quantity
    followers.count
  end

  def followed_quantity
    followed_users.count
  end

end
