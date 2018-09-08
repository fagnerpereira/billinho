class Registration < ApplicationRecord
  belongs_to :student
  belongs_to :institution

  validates :amount, :bills_count, :bill_expiry_day, :course_name, presence: true
  validates :amount, :bills_count, numericality: { greater_than: 0 }
  validates :bill_expiry_day, numericality: { greater_than: 0, less_than: 31 }
end
