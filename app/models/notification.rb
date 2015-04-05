class Notification < ActiveRecord::Base
	NOTIFICATION_TYPE = ["Comment", "Favorite", "Following", "Draft","Custom"]
  belongs_to :receiver , :class_name => 'User'
  belongs_to :creator , :class_name => 'User'
  belongs_to :post

  def set_notification_data(title=nil, message=nil)
  	creator = User.find_by_id(self.creator.id)
  	post = Post.find_by_id(self.post.id)
  	case self.notification_type
  	when "Comment"
  		self.title = "#{self.creator.username} has comment one of your Posts!"
  	when "Favorite"
  		self.title = "#{self.creator.username} has marked as favorite one of your Posts!"
		when "Following"
  		self.title = "#{self.creator.username} has start to following you!"
  	when "Draft"
  		self.title = "#{self.post.title} is still in draft!"
  	when "Custom"
  		if title then self.title = title end
  		if message then self.message = message end
  	end
    self.save!
  end
end
