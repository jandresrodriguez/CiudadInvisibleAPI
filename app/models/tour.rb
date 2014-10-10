class Tour < ActiveRecord::Base
  belongs_to :user

  has_many :part_of_tours
  has_many :posts, through: :part_of_tours, source: :post

end
