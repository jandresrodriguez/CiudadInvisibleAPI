class PostsCategories < ActiveRecord::Migration
  def change
  	create_table :posts_categories do |t|
      t.references :post, index: true
      t.references :category, index: true

      t.timestamps
    end
  end
end
