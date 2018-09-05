class CreateStudents < ActiveRecord::Migration[5.1]
  def change
    create_table :students do |t|
      t.string :name
      t.date :birthday
      t.integer :phone_number
      t.string :gender
      t.string :payment_method

      t.timestamps
    end
  end
end
