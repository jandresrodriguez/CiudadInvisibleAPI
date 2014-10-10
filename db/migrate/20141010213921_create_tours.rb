class CreateTours < ActiveRecord::Migration
  def change
    create_table :tours do |t|
      t.references :user, index: true
      t.string :city
      t.integer :duration

      t.timestamps
    end
  end
end
