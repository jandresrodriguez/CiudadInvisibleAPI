class ChangeOrderName < ActiveRecord::Migration
  def change
    rename_column :part_of_tours, :order, :tour_order
  end
end
