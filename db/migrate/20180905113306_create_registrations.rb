class CreateRegistrations < ActiveRecord::Migration[5.1]
  def change
    create_table :registrations do |t|
      t.float :amount
      t.integer :bills_count
      t.integer :bill_expiry_day
      t.string :course_name

      t.timestamps
    end
  end
end
