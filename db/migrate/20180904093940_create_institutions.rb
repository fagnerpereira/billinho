class CreateInstitutions < ActiveRecord::Migration[5.1]
  def change
    create_table :institutions do |t|
      t.string :name
      t.integer :cnpj
      t.string :kind

      t.timestamps
    end
  end
end
