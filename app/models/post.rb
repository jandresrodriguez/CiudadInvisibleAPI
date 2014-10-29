class Post < ActiveRecord::Base

  belongs_to :user
  has_many :assets,  :dependent => :destroy
  accepts_nested_attributes_for :assets, allow_destroy: true

  has_many :post_types
  has_many :categories, through: :post_types, source: :category

  reverse_geocoded_by :latitude, :longitude,
  	:address => :location
  after_validation :reverse_geocode
  


  def first_image
  	unless assets.nil? || assets.empty?
  		assets.first.file.url
  	end
  end

  def author
    if user
      user.first_name + " " + user.last_name
    end
  end

  def favorites_quantity
    Favorite.where(post_id: id).count
  end

  def comments
    comments = Comment.where(post_id: id)
    returnable_array = []
    comments.each do |comment|
      json = {}
      json[:text] = comment.text
      json[:first_name] = comment.user.first_name
      json[:last_name] = comment.user.last_name
      json[:username] = comment.user.username
      json[:avatar] = comment.user.file_url
      returnable_array << json
    end
    returnable_array
  end
end
