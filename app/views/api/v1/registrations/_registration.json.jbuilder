json.extract! registration, :id, :amount, :bills_count, :bill_expiry_day, :course_name, :created_at, :updated_at
json.url registration_url(registration, format: :json)
