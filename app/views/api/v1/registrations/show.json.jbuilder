json.registration do
  json.partial! 'registration', registration: @registration
  json.invoices do
    json.array! @registration.invoices, partial: 'invoices/invoice', as: :invoice
  end
end
