class User < ActiveRecord::Base

	
	has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
	validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  	validates :username, presence: true
  	validates :first_name, presence: true
  	validates :last_name, presence: true
  	validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create }

  	def file_url
      # Concatela la url del host mas la de la imagen
      ActionController::Base.asset_host + avatar.url
    end

end
