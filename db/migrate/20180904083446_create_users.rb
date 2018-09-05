class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email
      t.uuid :access_token

      t.timestamps
    end
  end
end
