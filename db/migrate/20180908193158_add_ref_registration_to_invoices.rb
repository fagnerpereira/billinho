class AddRefRegistrationToInvoices < ActiveRecord::Migration[5.1]
  def change
    add_reference :invoices, :registration, foreign_key: true
  end
end
