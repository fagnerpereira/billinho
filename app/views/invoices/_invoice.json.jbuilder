json.extract! invoice, :id, :value, :expires_at, :status, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
