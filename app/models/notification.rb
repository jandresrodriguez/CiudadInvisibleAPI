class Notification < ActiveRecord::Base
	NOTIFICATION_TYPE = ["Comment", "Favorite", "Following", "Draft","Custom"]
  belongs_to :receiver , :class_name => 'User'
  belongs_to :creator , :class_name => 'User'
  belongs_to :post

  def set_notification_data(title=nil, message=nil)
  	creator = User.find_by_id(creator.id)
  	post = Post.find_by_id(post.id)
  	case type
  	when "Comment"
  		title = "#{creator.username} has comment one of your Posts!"
  	when "Favorite"
  		title = "#{user.username} has marked as favorite one of your Posts!"
		when "Following"
  		title = "#{user.username} has start to following you!"
  	when "Draft"
  		title = "#{post.title} is still in draft!"
  	when "Custom"
  		if title then title = title end
  		if message then message = message end
  	end
  end
end
