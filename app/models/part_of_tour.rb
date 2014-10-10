class PartOfTour < ActiveRecord::Base
  belongs_to :post
  belongs_to :tour
end
