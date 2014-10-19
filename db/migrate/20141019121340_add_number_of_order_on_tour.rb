class AddNumberOfOrderOnTour < ActiveRecord::Migration
  def change
  	add_column :part_of_tours, :order, :integer
  end
end
