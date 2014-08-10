class AddUrlAvatarToUser < ActiveRecord::Migration
  def change
  	add_column :users, :url_avatar, :string
  end
end
