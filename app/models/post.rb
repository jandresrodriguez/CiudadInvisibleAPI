class Post < ActiveRecord::Base

  belongs_to :user
  has_many :assets,  :dependent => :destroy
  accepts_nested_attributes_for :assets, allow_destroy: true

  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode
  
end
