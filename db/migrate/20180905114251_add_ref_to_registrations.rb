class AddRefToRegistrations < ActiveRecord::Migration[5.1]
  def change
    add_reference :registrations, :institution, foreign_key: true
    add_reference :registrations, :student, foreign_key: true
  end
end
