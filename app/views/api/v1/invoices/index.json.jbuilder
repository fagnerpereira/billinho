  json.invoices do
    json.array! @invoices, partial: 'invoice', as: :invoice
  end
