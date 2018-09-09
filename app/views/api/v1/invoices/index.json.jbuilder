  json.invoices do
    json.array! @registration.invoices, partial: 'invoice', as: :invoice
  end
