class AddTitleAndMessageToNotification < ActiveRecord::Migration
  def change
  	add_column :notifications, :title, :string
  	add_column :notifications, :message, :text
  end
end
