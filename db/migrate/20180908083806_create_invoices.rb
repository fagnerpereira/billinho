class CreateInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :invoices do |t|
      t.float :value
      t.date :expires_at
      t.string :status, default: 'open'

      t.timestamps
    end
  end
end
