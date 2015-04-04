class AddReceiverToNotification < ActiveRecord::Migration
  def change
  	add_column :notifications, :receiver_id, :integer
  	rename_column :notifications, :user_id, :creator_id
  end
end
