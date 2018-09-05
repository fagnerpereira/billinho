json.students do
  json.array! @students, partial: 'student', as: :student
end
