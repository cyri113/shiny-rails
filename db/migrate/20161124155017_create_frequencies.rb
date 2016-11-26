class CreateFrequencies < ActiveRecord::Migration[5.0]
  def change
    create_table :frequencies do |t|
      t.string :name
      t.decimal :percent

      t.timestamps
    end
  end
end
