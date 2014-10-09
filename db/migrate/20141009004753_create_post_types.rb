class CreatePostTypes < ActiveRecord::Migration
  def change
    create_table :post_types do |t|
      t.references :post, index: true
      t.references :category, index: true
      t.timestamps
    end
  end
end
