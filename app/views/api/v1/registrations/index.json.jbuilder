json.registrations do
  json.array! @registrations, partial: 'registration', as: :registration
end
