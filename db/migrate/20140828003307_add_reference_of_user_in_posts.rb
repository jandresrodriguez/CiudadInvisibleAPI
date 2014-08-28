class AddReferenceOfUserInPosts < ActiveRecord::Migration
  def change
  	remove_column :posts, :author
  	add_column :posts, :user_id, :integer, references: :users
  end
end
