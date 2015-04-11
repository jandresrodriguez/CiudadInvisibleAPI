class PartOfTour < ActiveRecord::Base
  belongs_to :post
  belongs_to :tour

  default_scope { order("tour_order") }

end
