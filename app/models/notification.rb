class Notification < ActiveRecord::Base
	NOTIFICATION_TYPE = ["Comment", "Favorite", "Following", "Draft"]
  belongs_to :user
  belongs_to :post
end
