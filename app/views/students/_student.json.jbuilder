json.extract! student, :id, :name, :birthday, :phone_number, :gender, :payment_method, :created_at, :updated_at
json.url student_url(student, format: :json)
