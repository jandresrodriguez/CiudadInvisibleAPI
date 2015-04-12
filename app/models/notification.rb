class Notification < ActiveRecord::Base
	NOTIFICATION_TYPE = ["Comment", "Favorite", "Following", "Draft", "Custom"]
  belongs_to :receiver , :class_name => 'User'
  belongs_to :creator , :class_name => 'User'
  belongs_to :post

  validates :notification_type, inclusion: { in: NOTIFICATION_TYPE }

  def set_notification_data(title=nil, message=nil, entity_id=nil)
    payload = {}
  	creator = User.find_by_id(self.creator.id)
  	case self.notification_type
  	when "Comment"
  		self.title = "#{self.creator.username} ha comentado en uno de sus posteos!"
      payload = {
        type: "Comment",
        entity_id: entity_id
      }
  	when "Favorite"
  		self.title = "#{self.creator.username} ha marcado como favorito uno de sus posteos!"
      payload = {
        type: "Favorite",
        entity_id: entity_id
      }
		when "Following"
  		self.title = "#{self.creator.username} te esta siguiendo!"
      payload = {
        type: "Following",
        entity_id: entity_id
      }
  	when "Draft"
      post = Post.find_by_id(self.post.id)
  		self.title = "#{self.post.title} continua en draft!"
      payload = {
        type: "Draft",
        entity_id: entity_id
      }
  	when "Custom"
  		if title then self.title = title end
  		if message then self.message = message end      
      payload = {
        type: "Custom",
        entity_id: entity_id
      }
  	end
    self.save!

    return payload
  end
end
