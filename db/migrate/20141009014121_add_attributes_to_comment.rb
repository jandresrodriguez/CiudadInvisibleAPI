class AddAttributesToComment < ActiveRecord::Migration
  def change
    add_column :comments, :text, :string
    add_column :comments, :likes, :integer
  end
end
