class Category < ActiveRecord::Base
	has_many :post_types
  	has_many :posts, through: :post_types, source: :post
end
