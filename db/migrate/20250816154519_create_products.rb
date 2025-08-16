class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :code
      t.string :name
      t.float :price
      t.text :description
      t.integer :stock

      t.timestamps
    end
  end
end
