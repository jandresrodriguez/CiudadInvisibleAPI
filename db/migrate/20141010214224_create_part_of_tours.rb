class CreatePartOfTours < ActiveRecord::Migration
  def change
    create_table :part_of_tours do |t|
      t.references :post, index: true
      t.references :tour, index: true

      t.timestamps
    end
  end
end
