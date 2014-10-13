class Tour < ActiveRecord::Base
  belongs_to :user

  has_many :part_of_tours
  has_many :posts, through: :part_of_tours, source: :post

  #Geocoder::Calculations.distance_between([47.858205,2.294359], [40.748433,-73.985655])

end
