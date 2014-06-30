class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.string :author
      t.string :description
      t.string :image
      t.datetime :date
      t.string :location
      t.string :category

      t.timestamps
    end
  end
end
