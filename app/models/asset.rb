class Asset < ActiveRecord::Base
  belongs_to :post

  has_attached_file :file, :styles => { 
  	:medium => "300x300>", 
  	:thumb => "100x100>",
  	:path => ":rails_root/public/images/:id/:filename",
    :url  => "/images/:id/:filename"
  	}
  validates_attachment_content_type :file, :content_type => /\Aimage\/.*\Z/


end