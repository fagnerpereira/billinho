class AddUserRefToInstitutions < ActiveRecord::Migration[5.1]
  def change
    add_reference :institutions, :user, foreign_key: true
  end
end
