class AddRotationToAsset < ActiveRecord::Migration
  def change
    add_column :assets, :rotation, :boolean, default: false
  end
end
