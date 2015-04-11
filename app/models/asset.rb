class Asset < ActiveRecord::Base
  belongs_to :post

  has_attached_file :file, :styles => { 
	:large => "x1136",
	:medium => "x592>",
  	:small => "x284>", 
  	:thumb => "100x100>",
  	}
  validates_attachment_content_type :file, :content_type => /\Aimage\/.*\Z/


  def file_url
    file.url
  end

end
